import 'package:bluetooth_scanner/bluetooth_scanner.dart';

sealed class ScanEvent {}

class ScanStarted extends ScanEvent {}

class ScanFinished extends ScanEvent {}

class DeviceFound extends ScanEvent {
  final BluetoothDevice device;

  DeviceFound(this.device);
}

class ScanError extends ScanEvent {
  final String message;

  ScanError(this.message);
}
