package xyz.olekslukian.bluetooth_scanner

import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import kotlin.test.assertTrue
import kotlin.test.assertFalse
import org.mockito.Mockito

internal class BluetoothScannerPluginTest {

    private fun createPlugin(): BluetoothScannerPlugin = BluetoothScannerPlugin()

    private fun mockResult(): MethodChannel.Result =
        Mockito.mock(MethodChannel.Result::class.java)

    private fun setPendingResult(plugin: BluetoothScannerPlugin, result: MethodChannel.Result) {
        val field = BluetoothScannerPlugin::class.java.getDeclaredField("pendingResult")
        field.isAccessible = true
        field.set(plugin, result)
    }

    private fun getPendingResult(plugin: BluetoothScannerPlugin): MethodChannel.Result? {
        val field = BluetoothScannerPlugin::class.java.getDeclaredField("pendingResult")
        field.isAccessible = true
        return field.get(plugin) as? MethodChannel.Result
    }

    @Test
    fun onMethodCall_unknownMethod_callsNotImplemented() {
        val plugin = createPlugin()
        val result = mockResult()

        plugin.onMethodCall(MethodCall("nonexistent_method", null), result)

        Mockito.verify(result).notImplemented()
    }

    @Test
    fun onRequestPermissionsResult_wrongRequestCode_returnsFalse() {
        val plugin = createPlugin()

        val handled = plugin.onRequestPermissionsResult(
            999,
            emptyArray(),
            intArrayOf()
        )

        assertFalse(handled)
    }

    @Test
    fun onRequestPermissionsResult_correctCode_allGranted_succeeds() {
        val plugin = createPlugin()
        val result = mockResult()
        setPendingResult(plugin, result)

        val handled = plugin.onRequestPermissionsResult(
            2,
            arrayOf("android.permission.BLUETOOTH_CONNECT"),
            intArrayOf(PackageManager.PERMISSION_GRANTED)
        )

        assertTrue(handled)
        Mockito.verify(result).success(true)
        assertTrue(getPendingResult(plugin) == null)
    }

    @Test
    fun onRequestPermissionsResult_correctCode_denied_succeeds() {
        val plugin = createPlugin()
        val result = mockResult()
        setPendingResult(plugin, result)

        val handled = plugin.onRequestPermissionsResult(
            2,
            arrayOf("android.permission.BLUETOOTH_CONNECT"),
            intArrayOf(PackageManager.PERMISSION_DENIED)
        )

        assertTrue(handled)
        Mockito.verify(result).success(false)
        assertTrue(getPendingResult(plugin) == null)
    }

    @Test
    fun onRequestPermissionsResult_correctCode_emptyResults_denied() {
        val plugin = createPlugin()
        val result = mockResult()
        setPendingResult(plugin, result)

        val handled = plugin.onRequestPermissionsResult(
            2,
            emptyArray(),
            intArrayOf()
        )

        assertTrue(handled)
        Mockito.verify(result).success(false)
    }

    @Test
    fun onRequestPermissionsResult_noPendingResult_handlesGracefully() {
        val plugin = createPlugin()

        val handled = plugin.onRequestPermissionsResult(
            2,
            arrayOf("android.permission.BLUETOOTH_CONNECT"),
            intArrayOf(PackageManager.PERMISSION_GRANTED)
        )

        assertTrue(handled)
    }

    @Test
    fun onRequestPermissionsResult_multiplePermissions_allGranted() {
        val plugin = createPlugin()
        val result = mockResult()
        setPendingResult(plugin, result)

        val handled = plugin.onRequestPermissionsResult(
            2,
            arrayOf(
                "android.permission.BLUETOOTH_CONNECT",
                "android.permission.BLUETOOTH_SCAN"
            ),
            intArrayOf(
                PackageManager.PERMISSION_GRANTED,
                PackageManager.PERMISSION_GRANTED
            )
        )

        assertTrue(handled)
        Mockito.verify(result).success(true)
    }

    @Test
    fun onRequestPermissionsResult_multiplePermissions_partiallyDenied() {
        val plugin = createPlugin()
        val result = mockResult()
        setPendingResult(plugin, result)

        val handled = plugin.onRequestPermissionsResult(
            2,
            arrayOf(
                "android.permission.BLUETOOTH_CONNECT",
                "android.permission.BLUETOOTH_SCAN"
            ),
            intArrayOf(
                PackageManager.PERMISSION_GRANTED,
                PackageManager.PERMISSION_DENIED
            )
        )

        assertTrue(handled)
        Mockito.verify(result).success(false)
    }
}
