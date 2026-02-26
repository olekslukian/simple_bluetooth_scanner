import 'package:bluetooth_scanner/src/bluetooth_scanner_method_channel.dart';
import 'package:bluetooth_scanner/src/models/bluetooth_device.dart';
import 'package:bluetooth_scanner/src/scan_event.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelBluetoothScanner platform;
  const MethodChannel channel = MethodChannel('bluetooth_scanner');
  const EventChannel eventChannel = EventChannel('bluetooth_scanner_events');

  setUp(() {
    platform = MethodChannelBluetoothScanner();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  void setMethodHandler(Future<Object?> Function(String method) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) => handler(call.method));
  }

  group('boolean methods', () {
    final methods = {
      'isBluetoothSupported': 'is_bluetooth_supported',
      'hasBluetoothPermissions': 'has_bluetooth_permissions',
      'requestBluetoothPermissions': 'request_bluetooth_permissions',
      'isBluetoothEnabled': 'is_bluetooth_enabled',
      'enableBluetooth': 'enable_bluetooth',
      'stopDiscovery': 'stop_discovery',
      'isDiscovering': 'is_discovering',
    };

    for (final entry in methods.entries) {
      test('${entry.key} calls ${entry.value} and returns true', () async {
        setMethodHandler((_) async => true);

        final Future<bool> result = switch (entry.key) {
          'isBluetoothSupported' => platform.isBluetoothSupported(),
          'hasBluetoothPermissions' => platform.hasBluetoothPermissions(),
          'requestBluetoothPermissions' =>
            platform.requestBluetoothPermissions(),
          'isBluetoothEnabled' => platform.isBluetoothEnabled(),
          'enableBluetooth' => platform.enableBluetooth(),
          'stopDiscovery' => platform.stopDiscovery(),
          'isDiscovering' => platform.isDiscovering(),
          _ => throw StateError('Unknown method'),
        };

        expect(await result, true);
      });

      test('${entry.key} returns false when native returns null', () async {
        setMethodHandler((_) async => null);

        final Future<bool> result = switch (entry.key) {
          'isBluetoothSupported' => platform.isBluetoothSupported(),
          'hasBluetoothPermissions' => platform.hasBluetoothPermissions(),
          'requestBluetoothPermissions' =>
            platform.requestBluetoothPermissions(),
          'isBluetoothEnabled' => platform.isBluetoothEnabled(),
          'enableBluetooth' => platform.enableBluetooth(),
          'stopDiscovery' => platform.stopDiscovery(),
          'isDiscovering' => platform.isDiscovering(),
          _ => throw StateError('Unknown method'),
        };

        expect(await result, false);
      });
    }
  });

  group('getPairedDevices', () {
    test('returns null when native returns null', () async {
      setMethodHandler((_) async => null);
      expect(await platform.getPairedDevices(), isNull);
    });

    test('returns empty list when native returns empty list', () async {
      setMethodHandler((_) async => <Object?>[]);
      expect(await platform.getPairedDevices(), isEmpty);
    });

    test('deserializes devices correctly', () async {
      setMethodHandler(
        (_) async => [
          {
            'name': 'Test Device',
            'alias': 'My Device',
            'address': '00:11:22:33:44:55',
            'rssi': -50,
          },
        ],
      );

      final devices = await platform.getPairedDevices();
      expect(devices, isNotNull);
      expect(devices!.length, 1);
      expect(
        devices[0],
        BluetoothDevice(
          name: 'Test Device',
          alias: 'My Device',
          address: '00:11:22:33:44:55',
          rssi: -50,
        ),
      );
    });

    test('handles nullable device fields', () async {
      setMethodHandler(
        (_) async => [
          {'name': null, 'alias': null, 'address': null, 'rssi': null},
        ],
      );

      final devices = await platform.getPairedDevices();
      expect(devices!.length, 1);
      expect(devices[0].name, isNull);
      expect(devices[0].address, isNull);
    });
  });

  group('startDiscovery', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(eventChannel, null);
    });

    void setStreamEvents(List<Object?> events) {
      setMethodHandler((_) async => null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(
            eventChannel,
            MockStreamHandler.inline(
              onListen: (_, sink) {
                for (final event in events) {
                  sink.success(event);
                }
                sink.endOfStream();
              },
            ),
          );
    }

    test('emits DeviceFound event', () async {
      setStreamEvents([
        {
          'type': 'device_found',
          'device': {
            'name': 'Found Device',
            'alias': null,
            'address': 'AA:BB:CC:DD:EE:FF',
            'rssi': -70,
          },
        },
      ]);

      final events = await platform.startDiscovery().toList();
      expect(events.length, 1);
      expect(events[0], isA<DeviceFound>());
      final found = events[0] as DeviceFound;
      expect(found.device.name, 'Found Device');
      expect(found.device.address, 'AA:BB:CC:DD:EE:FF');
      expect(found.device.rssi, -70);
    });

    test('emits ScanStarted event', () async {
      setStreamEvents([
        {'type': 'scan_started'},
      ]);

      final events = await platform.startDiscovery().toList();
      expect(events.length, 1);
      expect(events[0], isA<ScanStarted>());
    });

    test('emits ScanFinished event', () async {
      setStreamEvents([
        {'type': 'scan_finished'},
      ]);

      final events = await platform.startDiscovery().toList();
      expect(events.length, 1);
      expect(events[0], isA<ScanFinished>());
    });

    test('emits multiple events in order', () async {
      setStreamEvents([
        {'type': 'scan_started'},
        {
          'type': 'device_found',
          'device': {
            'name': 'Device A',
            'alias': null,
            'address': '00:00:00:00:00:01',
            'rssi': -60,
          },
        },
        {
          'type': 'device_found',
          'device': {
            'name': 'Device B',
            'alias': null,
            'address': '00:00:00:00:00:02',
            'rssi': -80,
          },
        },
        {'type': 'scan_finished'},
      ]);

      final events = await platform.startDiscovery().toList();
      expect(events.length, 4);
      expect(events[0], isA<ScanStarted>());
      expect(events[1], isA<DeviceFound>());
      expect(events[2], isA<DeviceFound>());
      expect(events[3], isA<ScanFinished>());
      expect((events[1] as DeviceFound).device.name, 'Device A');
      expect((events[2] as DeviceFound).device.name, 'Device B');
    });

    test('throws StateError on unknown event type', () async {
      setStreamEvents([
        {'type': 'unknown_event'},
      ]);

      await expectLater(
        platform.startDiscovery().toList(),
        throwsStateError,
      );
    });
  });
}
