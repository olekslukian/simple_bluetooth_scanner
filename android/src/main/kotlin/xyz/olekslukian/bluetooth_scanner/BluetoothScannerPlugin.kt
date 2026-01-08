package xyz.olekslukian.bluetooth_scanner

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class BluetoothScannerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  private var pendingResult: Result? = null

  companion object {
    private const val REQUEST_ENABLE_BT = 1
  }

  private var bluetoothAdapter: BluetoothAdapter? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "bluetooth_scanner")
    methodChannel.setMethodCallHandler(this)

    context = flutterPluginBinding.applicationContext
  }

  fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == REQUEST_ENABLE_BT) {
      if (resultCode == Activity.RESULT_OK) {
        pendingResult?.success("Bluetooth enabled successfully")
      } else {
        pendingResult?.error("bluetooth_not_enabled", "User declined to enable Bluetooth", null)
      }

      pendingResult = null

      return true
    }
    return false
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity

    binding.addActivityResultListener { requestCode, resultCode, intent ->
      onActivityResult(requestCode, resultCode, intent)
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "init_bluetooth_adapter" -> initBluetoothAdapter(context, activity, result)
      "get_paired_devices" -> getPairedDevices(result)
      "get_platform_version" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }

  fun initBluetoothAdapter(appContext: Context, activity: Activity, result: Result) {
    val bluetoothManager: BluetoothManager? =
      getSystemService(appContext, BluetoothManager::class.java)
    bluetoothAdapter = bluetoothManager?.adapter

    if (bluetoothAdapter == null) {
      result.error("not_supported", "Device doesn't support Bluetooth", null)
    }

    if (bluetoothAdapter?.isEnabled == false) {
      pendingResult = result

      val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
      activity.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT)
    } else {
      result.success("Bluetooth adapter successfully initialized")
    }

  }

  fun getPairedDevices(result: Result) {
    val pairedDevices: Set<BluetoothDevice>? = bluetoothAdapter?.bondedDevices
    val devicesList = pairedDevices?.map { device ->
      hashMapOf("name" to device.name,
        "address" to device.address,
        )
    }

    result.success(devicesList);
  }
}
