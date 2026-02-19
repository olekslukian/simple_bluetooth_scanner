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
  Future<bool> isBluetoothSupported() async {
    final result = await methodChannel.invokeMethod<bool>(
      'is_bluetooth_supported',
    );
    return result ?? false;
  }

  @override
  Future<bool> hasBluetoothPermissions() async {
    final result = await methodChannel.invokeMethod<bool>(
      'has_bluetooth_permissions',
    );
    return result ?? false;
  }

  @override
  Future<bool> requestBluetoothPermissions() async {
    final result = await methodChannel.invokeMethod<bool>(
      'request_bluetooth_permissions',
    );
    return result ?? false;
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    final result = await methodChannel.invokeMethod<bool>(
      'is_bluetooth_enabled',
    );
    return result ?? false;
  }

  @override
  Future<bool> enableBluetooth() async {
    final result = await methodChannel.invokeMethod<bool>('enable_bluetooth');
    return result ?? false;
  }

  @override
  Future<List<BluetoothDevice>?> getPairedDevices() async {
    final result = await methodChannel.invokeMethod<List<Object?>>(
      'get_paired_devices',
    );

    if (result == null) return null;

    return result.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return BluetoothDevice.fromMap(map);
    }).toList();
  }
}
