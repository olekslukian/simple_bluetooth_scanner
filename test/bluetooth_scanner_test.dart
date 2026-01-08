import 'package:flutter_test/flutter_test.dart';
import 'package:bluetooth_scanner/bluetooth_scanner.dart';
import 'package:bluetooth_scanner/src/bluetooth_scanner_platform_interface.dart';
import 'package:bluetooth_scanner/src/bluetooth_scanner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';


class MockBluetoothScannerPlatform
    with MockPlatformInterfaceMixin
    implements BluetoothScannerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BluetoothScannerPlatform initialPlatform = BluetoothScannerPlatform.instance;

  test('$MethodChannelBluetoothScanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBluetoothScanner>());
  });

  test('getPlatformVersion', () async {
    BluetoothScanner bluetoothScannerPlugin = BluetoothScanner();
    MockBluetoothScannerPlatform fakePlatform = MockBluetoothScannerPlatform();
    BluetoothScannerPlatform.instance = fakePlatform;

    expect(await bluetoothScannerPlugin.getPlatformVersion(), '42');
  });
}
