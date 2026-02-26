import 'package:bluetooth_scanner/src/bluetooth_scanner_platform_interface.dart';
import 'package:bluetooth_scanner/src/models/bluetooth_device.dart';
import 'package:bluetooth_scanner/src/scan_event.dart';

class BluetoothScanner {
  const BluetoothScanner({bool enableLogging = false});

  Future<bool> isBluetoothSupported() {
    return BluetoothScannerPlatform.instance.isBluetoothSupported();
  }

  Future<bool> hasBluetoothPermissions() {
    return BluetoothScannerPlatform.instance.hasBluetoothPermissions();
  }

  Future<bool> requestBluetoothPermissions() {
    return BluetoothScannerPlatform.instance.requestBluetoothPermissions();
  }

  Future<bool> isBluetoothEnabled() {
    return BluetoothScannerPlatform.instance.isBluetoothEnabled();
  }

  Future<bool> enableBluetooth() {
    return BluetoothScannerPlatform.instance.enableBluetooth();
  }

  Future<List<BluetoothDevice>?> getPairedDevices() {
    return BluetoothScannerPlatform.instance.getPairedDevices();
  }

  Stream<ScanEvent> startDiscovery() {
    return BluetoothScannerPlatform.instance.startDiscovery();
  }

  Future<bool> stopDiscovery() {
    return BluetoothScannerPlatform.instance.stopDiscovery();
  }

  Future<bool> isDiscovering() {
    return BluetoothScannerPlatform.instance.isDiscovering();
  }
}
