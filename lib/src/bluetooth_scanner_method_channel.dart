import 'package:bluetooth_scanner/src/models/bluetooth_device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluetooth_scanner_platform_interface.dart';

class MethodChannelBluetoothScanner extends BluetoothScannerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('bluetooth_scanner');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'get_platform_version',
    );
    return version;
  }

  @override
  Future<bool> enableBluetooth() {
    // TODO: implement enableBluetooth
    throw UnimplementedError();
  }

  @override
  Future<bool> hasBluetoothPermissions() {
    // TODO: implement hasBluetoothPermissions
    throw UnimplementedError();
  }

  @override
  Future<bool> isBluetoothEnabled() {
    // TODO: implement isBluetoothEnabled
    throw UnimplementedError();
  }

  @override
  Future<bool> isBluetoothSupported() {
    // TODO: implement isBluetoothSupported
    throw UnimplementedError();
  }

  @override
  Future<bool> requestBluetoothPermissions() {
    // TODO: implement requestBluetoothPermissions
    throw UnimplementedError();
  }

  @override
  Future<List<BluetoothDevice>?> getPairedDevices() {
    // TODO: implement getPairedDevices
    throw UnimplementedError();
  }
}
