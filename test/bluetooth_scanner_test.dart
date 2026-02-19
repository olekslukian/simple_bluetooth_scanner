import 'package:flutter_test/flutter_test.dart';
import 'package:bluetooth_scanner/bluetooth_scanner.dart';
import 'package:bluetooth_scanner/src/bluetooth_scanner_platform_interface.dart';
import 'package:bluetooth_scanner/src/bluetooth_scanner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock implementation of BluetoothScannerPlatform for testing.
///
/// This class implements all methods from the platform interface,
/// returning predictable values for unit tests.
class MockBluetoothScannerPlatform
    with MockPlatformInterfaceMixin
    implements BluetoothScannerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

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
}

void main() {
  final BluetoothScannerPlatform initialPlatform = BluetoothScannerPlatform.instance;

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

    test('getPlatformVersion returns expected value', () async {
      expect(await bluetoothScanner.getPlatformVersion(), '42');
    });

    test('isBluetoothSupported returns expected value', () async {
      expect(await bluetoothScanner.isBluetoothSupported(), true);
    });

    test('hasBluetoothPermissions returns expected value', () async {
      expect(await bluetoothScanner.hasBluetoothPermissions(), true);
    });

    test('requestBluetoothPermissions returns expected value', () async {
      expect(await bluetoothScanner.requestBluetoothPermissions(), true);
    });

    test('isBluetoothEnabled returns expected value', () async {
      expect(await bluetoothScanner.isBluetoothEnabled(), true);
    });

    test('enableBluetooth returns expected value', () async {
      expect(await bluetoothScanner.enableBluetooth(), true);
    });

    test('getPairedDevices returns list of devices', () async {
      final devices = await bluetoothScanner.getPairedDevices();
      expect(devices, isNotNull);
      expect(devices!.length, 1);
      expect(devices[0].name, 'Test Device');
      expect(devices[0].address, '00:11:22:33:44:55');
    });
  });
}
