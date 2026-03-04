# bluetooth_scanner

A Flutter plugin for Bluetooth device scanning and management.

**Status:** In development

## Platform Support

- Android: API 21+ (implemented)
- iOS: Planned (stub only)

## Installation

```yaml
dependencies:
  bluetooth_scanner: ^0.0.1
```

## Usage

No initialization required. Create an instance and call methods directly.

```dart
import 'package:bluetooth_scanner/bluetooth_scanner.dart';

final scanner = BluetoothScanner();
```

### Check Bluetooth support and state

```dart
final supported = await scanner.isBluetoothSupported();
final enabled = await scanner.isBluetoothEnabled();
```

### Permissions

```dart
final hasPermissions = await scanner.hasBluetoothPermissions();

if (!hasPermissions) {
  final granted = await scanner.requestBluetoothPermissions();
}
```

### Enable Bluetooth

Prompts the user to enable Bluetooth if it is disabled.

```dart
final enabled = await scanner.enableBluetooth();
```

### Paired devices

```dart
final devices = await scanner.getPairedDevices();

for (final device in devices ?? []) {
  print('${device.name} - ${device.address}');
}
```

### Device discovery

```dart
final subscription = scanner.startDiscovery().listen((event) {
  switch (event) {
    case ScanStarted():
      print('Scan started');
    case DeviceFound(:final device):
      print('Found: ${device.name} (${device.address}), RSSI: ${device.rssi}');
    case ScanFinished():
      print('Scan finished');
    case ScanError(:final message):
      print('Error: $message');
    case ScanNotStarted():
      break;
  }
});

// Stop discovery early if needed
await scanner.stopDiscovery();

// Check if discovery is in progress
final discovering = await scanner.isDiscovering();
```

## Error handling

Platform methods throw `PlatformException` with these codes:

| Code | Meaning |
|------|---------|
| `UNSUPPORTED` | Bluetooth hardware not available |
| `NO_PERMISSION` | Missing Bluetooth permission |
| `NO_SCAN_PERMISSION` | Missing scan/location permission |
| `DISABLED` | Bluetooth is turned off |
| `NO_ACTIVITY` | Plugin not attached to an activity |


