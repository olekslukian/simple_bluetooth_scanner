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
  Future<void> initBluetoothAdapter() async =>
      await methodChannel.invokeMethod<void>('init_bluetooth_adapter');

  @override
  Future<List<BluetoothDevice>?> getPairedDevices() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'get_paired_devices',
    );

    if (result != null) {
      final devices = result.map((item) {
        return BluetoothDevice.fromMap(Map<String, dynamic>.from(item));
      }).toList();

      return devices;
    }
    return null;
  }
}
