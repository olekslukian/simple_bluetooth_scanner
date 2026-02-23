package xyz.olekslukian.bluetooth_scanner

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


class BluetoothScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener, EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: Result? = null

    private var bluetoothAdapter: BluetoothAdapter? = null

    private var eventSink: EventChannel.EventSink? = null
    private var discoveryReceiver: BroadcastReceiver? = null
    private var isReceiverRegistered = false

    companion object {
        private const val REQUEST_ENABLE_BT = 1
        private const val REQUEST_BLUETOOTH_PERMISSIONS = 2

        private const val METHOD_CHANNEL_NAME = "bluetooth_scanner"
        private const val EVENT_CHANNEL_NAME = "bluetooth_scanner_events"
    }


   override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)

        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopDiscoveryInternal()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding

        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener { requestCode, resultCode, _ ->
            handleActivityResult(requestCode, resultCode)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener { requestCode, resultCode, _ ->
            handleActivityResult(requestCode, resultCode)
        }
    }

   override fun onDetachedFromActivity() {
        stopDiscoveryInternal()

        pendingResult?.error("ACTIVITY_DETACHED", "Activity was destroyed", null)
        pendingResult = null

        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "get_platform_version" -> result.success("Android ${Build.VERSION.RELEASE}")
            "is_bluetooth_supported" -> isBluetoothSupported(result)
            "has_bluetooth_permissions" -> hasBluetoothPermissions(result)
            "request_bluetooth_permissions" -> requestBluetoothPermissions(result)
            "is_bluetooth_enabled" -> isBluetoothEnabled(result)
            "enable_bluetooth" -> enableBluetooth(result)
            "get_paired_devices" -> getPairedDevices(result)
            "start_discovery" -> startDiscovery(result)
            "stop_discovery" -> stopDiscovery(result)
            "is_discovering" -> isDiscovering(result)
            else -> result.notImplemented()
        }
    }


   override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != REQUEST_BLUETOOTH_PERMISSIONS) {
            return false
        }

        val allGranted = grantResults.isNotEmpty() &&
                grantResults.all { it == PackageManager.PERMISSION_GRANTED }

        pendingResult?.success(allGranted)
        pendingResult = null

        return true
    }


   private fun handleActivityResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode != REQUEST_ENABLE_BT) {
            return false
        }

        if (resultCode == Activity.RESULT_OK) {
            pendingResult?.success(true)
        } else {
            pendingResult?.success(false)
        }

        pendingResult = null
        return true
    }


   private fun isBluetoothSupported(result: Result) {
        ensureBluetoothAdapter()
        result.success(bluetoothAdapter != null)
    }

   private fun hasBluetoothPermissionsSync(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH
            ) == PackageManager.PERMISSION_GRANTED
        }
    }


    private fun hasBluetoothPermissions(result: Result) {
        result.success(hasBluetoothPermissionsSync())
    }

   private fun requestBluetoothPermissions(result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Plugin not attached to an activity", null)
            return
        }

        if (hasBluetoothPermissionsSync()) {
            result.success(true)
            return
        }

        pendingResult = result

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.requestPermissions(
                currentActivity,
                arrayOf(
                    Manifest.permission.BLUETOOTH_CONNECT,
                    Manifest.permission.BLUETOOTH_SCAN
                ),
                REQUEST_BLUETOOTH_PERMISSIONS
            )
        } else {
            ActivityCompat.requestPermissions(
                currentActivity,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                REQUEST_BLUETOOTH_PERMISSIONS
            )
        }
    }


    private fun isBluetoothEnabled(result: Result) {
        ensureBluetoothAdapter()

        if (bluetoothAdapter == null) {
            result.error("UNSUPPORTED", "Bluetooth not supported on this device", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !hasBluetoothPermissionsSync()) {
            result.error("NO_PERMISSION", "BLUETOOTH_CONNECT permission required", null)
            return
        }

        try {
            result.success(bluetoothAdapter?.isEnabled == true)
        } catch (e: SecurityException) {
            result.error("NO_PERMISSION", "Missing Bluetooth permission: ${e.message}", null)
        }
    }


    private fun enableBluetooth(result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Plugin not attached to an activity", null)
            return
        }

        ensureBluetoothAdapter()

        if (bluetoothAdapter == null) {
            result.error("UNSUPPORTED", "Bluetooth not supported on this device", null)
            return
        }

        try {
            if (bluetoothAdapter?.isEnabled == true) {
                result.success(true)
                return
            }
        } catch (e: SecurityException) {
            result.error("NO_PERMISSION", "Bluetooth permission required", null)
            return
        }

        pendingResult = result

        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        currentActivity.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT)
    }

    private fun getPairedDevices(result: Result) {
        ensureBluetoothAdapter()

        if (bluetoothAdapter == null) {
            result.error("UNSUPPORTED", "Bluetooth not supported on this device", null)
            return
        }

        if (!hasBluetoothPermissionsSync()) {
            result.error("NO_PERMISSION", "Bluetooth permission required", null)
            return
        }

        try {
            val pairedDevices: Set<BluetoothDevice>? = bluetoothAdapter?.bondedDevices
            val devicesList = pairedDevices?.map { device ->
                hashMapOf(
                    "name" to device.name,
                    "address" to device.address
                )
            } ?: emptyList()

            result.success(devicesList)
        } catch (e: SecurityException) {
            result.error("NO_PERMISSION", "Missing Bluetooth permission: ${e.message}", null)
        }
    }

        private fun ensureBluetoothAdapter() {
        if (bluetoothAdapter == null) {
            val bluetoothManager = ContextCompat.getSystemService(context, BluetoothManager::class.java)
            bluetoothAdapter = bluetoothManager?.adapter
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        stopDiscoveryInternal()
        eventSink = null
    }

    private fun hasScanPermissionsSync(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_SCAN
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun startDiscovery(result: Result) {
        ensureBluetoothAdapter()

        if (bluetoothAdapter == null) {
            result.error("UNSUPPORTED", "Bluetooth not supported on this device", null)
            return
        }

        if (!hasScanPermissionsSync()) {
            result.error("NO_SCAN_PERMISSION", "Bluetooth scan permission required", null)
            return
        }

        try {
            if (bluetoothAdapter?.isEnabled != true) {
                result.error("DISABLED", "Bluetooth is not enabled", null)
                return
            }
        } catch (e: SecurityException) {
            result.error("NO_PERMISSION", "Missing Bluetooth permission: ${e.message}", null)
            return
        }

        if (bluetoothAdapter?.isDiscovering == true) {
            bluetoothAdapter?.cancelDiscovery()
            unregisterDiscoveryReceiver()
        }

        discoveryReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    BluetoothDevice.ACTION_FOUND -> {
                        val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        }

                        if (device != null) {
                            try {
                                val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE).toInt()
                                val deviceMap = hashMapOf<String, Any?>(
                                    "name" to device.name,
                                    "address" to device.address,
                                    "rssi" to if (rssi != Short.MIN_VALUE.toInt()) rssi else null
                                )

                                eventSink?.success(hashMapOf(
                                    "type" to "device_found",
                                    "device" to deviceMap
                                ))
                            } catch (e: SecurityException) {
                                eventSink?.error("NO_PERMISSION", "Missing Bluetooth permission: ${e.message}", null)
                            }
                        }
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                        eventSink?.success(hashMapOf("type" to "scan_finished"))
                        eventSink?.endOfStream()
                        unregisterDiscoveryReceiver()
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        context.registerReceiver(discoveryReceiver, filter)
        isReceiverRegistered = true

        val started = bluetoothAdapter?.startDiscovery() == true
        if (started) {
            eventSink?.success(hashMapOf("type" to "scan_started"))
            result.success(true)
        } else {
            unregisterDiscoveryReceiver()
            result.error("SCAN_FAILED", "Failed to start discovery", null)
        }
    }

    private fun stopDiscovery(result: Result) {
        stopDiscoveryInternal()
        result.success(true)
    }

    private fun isDiscovering(result: Result) {
        ensureBluetoothAdapter()
        try {
            result.success(bluetoothAdapter?.isDiscovering == true)
        } catch (e: SecurityException) {
            result.error("NO_PERMISSION", "Missing Bluetooth permission: ${e.message}", null)
        }
    }

    private fun stopDiscoveryInternal() {
        try {
            if (bluetoothAdapter?.isDiscovering == true) {
                bluetoothAdapter?.cancelDiscovery()
            }
        } catch (_: SecurityException) {}

        if (isReceiverRegistered) {
            eventSink?.success(hashMapOf("type" to "scan_finished"))
            eventSink?.endOfStream()
        }

        unregisterDiscoveryReceiver()
    }

    private fun unregisterDiscoveryReceiver() {
        if (isReceiverRegistered) {
            try {
                context.unregisterReceiver(discoveryReceiver)
            } catch (_: IllegalArgumentException) {}
            isReceiverRegistered = false
        }
        discoveryReceiver = null
    }
}
