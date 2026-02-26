import 'package:bluetooth_scanner/bluetooth_scanner.dart';

sealed class ScanEvent {
  const ScanEvent();

  factory ScanEvent.notStarted() => ScanNotStarted();
  factory ScanEvent.deviceFound(BluetoothDevice device) => DeviceFound(device);
  factory ScanEvent.finished() => ScanFinished();
  factory ScanEvent.started() => ScanStarted();
  factory ScanEvent.error(String message) => ScanError(message);
}

class ScanNotStarted extends ScanEvent {}

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
