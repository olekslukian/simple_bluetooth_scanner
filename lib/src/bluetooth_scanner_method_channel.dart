import 'package:bluetooth_scanner/src/models/bluetooth_device.dart';
import 'package:bluetooth_scanner/src/scan_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluetooth_scanner_platform_interface.dart';

class MethodChannelBluetoothScanner extends BluetoothScannerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('bluetooth_scanner');

  @visibleForTesting
  final eventChannel = const EventChannel('bluetooth_scanner_events');

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

  @override
  Stream<ScanEvent> startDiscovery() {
    methodChannel.invokeMethod<bool>('start_discovery');
    return eventChannel.receiveBroadcastStream().map((event) {
      final map = Map<String, dynamic>.from(event as Map);
      return switch (map['type'] as String) {
        'scan_started' => ScanStarted(),
        'device_found' => DeviceFound(
          BluetoothDevice.fromMap(
            Map<String, dynamic>.from(map['device'] as Map),
          ),
        ),
        'scan_finished' => ScanFinished(),
        _ => throw StateError('Unknown scan event type: ${map['type']}'),
      };
    });
  }

  @override
  Future<bool> stopDiscovery() async {
    final result = await methodChannel.invokeMethod<bool>('stop_discovery');
    return result ?? false;
  }

  @override
  Future<bool> isDiscovering() async {
    final result = await methodChannel.invokeMethod<bool>('is_discovering');
    return result ?? false;
  }
}
