# bluetooth_scanner

A Flutter plugin for Bluetooth device scanning and management.

**Status:** In development

## Overview

This plugin provides a simple API for working with Bluetooth on Android and iOS devices. It allows you to check Bluetooth availability, manage permissions, enable Bluetooth, and access paired devices.

### Features

- Check if Bluetooth is supported on the device
- Request and manage Bluetooth permissions
- Enable/disable Bluetooth adapter
- Get list of paired devices
- No initialization required - just create an instance and start using methods

### Platform Support

- Android: API 21+ (partial implementation)
- iOS: Planned (stub only)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  bluetooth_scanner: ^0.0.1
```

## Usage

```dart
import 'package:bluetooth_scanner/bluetooth_scanner.dart';

final scanner = BluetoothScanner();

// Check if Bluetooth is supported
final supported = await scanner.isBluetoothSupported();

// Get paired devices
final devices = await scanner.getPairedDevices();
```

