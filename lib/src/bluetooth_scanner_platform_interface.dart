import 'package:bluetooth_scanner/src/models/bluetooth_device.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bluetooth_scanner_method_channel.dart';

abstract class BluetoothScannerPlatform extends PlatformInterface {
  BluetoothScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static BluetoothScannerPlatform _instance = MethodChannelBluetoothScanner();

  static BluetoothScannerPlatform get instance => _instance;

  static set instance(BluetoothScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();

  Future<bool> hasBluetoothPermissions();
  Future<bool> requestBluetoothPermissions();

  Future<bool> isBluetoothSupported();
  Future<bool> isBluetoothEnabled();
  Future<bool> enableBluetooth();

  Future<List<BluetoothDevice>?> getPairedDevices();
}
