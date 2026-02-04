import 'package:bluetooth_scanner/src/bluetooth_scanner_platform_interface.dart';
import 'package:bluetooth_scanner/src/models/bluetooth_device.dart';

class BluetoothScanner {
  const BluetoothScanner({bool enableLogging = false});

  Future<String?> getPlatformVersion() {
    return BluetoothScannerPlatform.instance.getPlatformVersion();
  }

  Future<List<BluetoothDevice>?> getPairedDevices() {
    return BluetoothScannerPlatform.instance.getPairedDevices();
  }
}
