import 'package:flutter_test/flutter_test.dart';
import 'package:bluetooth_scanner/bluetooth_scanner.dart';
import 'package:bluetooth_scanner/src/bluetooth_scanner_platform_interface.dart';
import 'package:bluetooth_scanner/src/bluetooth_scanner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBluetoothScannerPlatform
    with MockPlatformInterfaceMixin
    implements BluetoothScannerPlatform {
  @override
  Future<bool> isBluetoothSupported() => Future.value(true);

  @override
  Future<bool> hasBluetoothPermissions() => Future.value(true);

  @override
  Future<bool> requestBluetoothPermissions() => Future.value(true);

  @override
  Future<bool> isBluetoothEnabled() => Future.value(true);

  @override
  Future<bool> enableBluetooth() => Future.value(true);

  @override
  Future<List<BluetoothDevice>?> getPairedDevices() => Future.value([
    BluetoothDevice(
      name: 'Test Device',
      alias: 'My Device',
      address: '00:11:22:33:44:55',
      rssi: -50,
    ),
  ]);

  @override
  Future<bool> isDiscovering() => Future.value(true);

  @override
  Stream<ScanEvent> startDiscovery() {
    return Stream.fromIterable([
      ScanEvent.deviceFound(
        BluetoothDevice(
          name: 'Discovered Device',
          alias: 'My Discovered Device',
          address: 'AA:BB:CC:DD:EE:FF',
          rssi: -70,
        ),
      ),
      ScanEvent.finished(),
    ]);
  }

  @override
  Future<bool> stopDiscovery() => Future.value(true);
}

void main() {
  final BluetoothScannerPlatform initialPlatform =
      BluetoothScannerPlatform.instance;

  test('\$MethodChannelBluetoothScanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBluetoothScanner>());
  });

  group('BluetoothScanner', () {
    late BluetoothScanner bluetoothScanner;
    late MockBluetoothScannerPlatform mockPlatform;

    setUp(() {
      bluetoothScanner = const BluetoothScanner();
      mockPlatform = MockBluetoothScannerPlatform();
      BluetoothScannerPlatform.instance = mockPlatform;
    });

    test('getPairedDevices returns list of devices', () async {
      final devices = await bluetoothScanner.getPairedDevices();
      expect(devices, isNotNull);
      expect(devices!.length, 1);
      expect(devices[0].name, 'Test Device');
      expect(devices[0].address, '00:11:22:33:44:55');
    });

    test('startDiscovery emits scan events', () async {
      final events = await bluetoothScanner.startDiscovery().toList();
      expect(events.length, 2);
      expect(events[0], isA<DeviceFound>());
      expect((events[0] as DeviceFound).device.name, 'Discovered Device');
      expect(events[1], isA<ScanFinished>());
    });
  });
}
