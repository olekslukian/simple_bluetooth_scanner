import 'package:bluetooth_scanner/src/bluetooth_scanner_platform_interface.dart';
import 'package:bluetooth_scanner/src/models/bluetooth_device.dart';

class BluetoothScanner {
  /// Creates a BluetoothScanner instance.
  ///
  /// [enableLogging] - When true, enables debug logging (not yet implemented).
  const BluetoothScanner({bool enableLogging = false});

  /// Gets the platform version string.
  ///
  /// Returns "Android X.X" or "iOS X.X" depending on platform.
  Future<String?> getPlatformVersion() {
    return BluetoothScannerPlatform.instance.getPlatformVersion();
  }

  /// Checks if the device has Bluetooth hardware.
  ///
  /// This should be called first before any other Bluetooth operations.
  /// Does not require any permissions.
  ///
  /// Returns `true` if Bluetooth is supported on this device.
  Future<bool> isBluetoothSupported() {
    return BluetoothScannerPlatform.instance.isBluetoothSupported();
  }

  /// Checks if Bluetooth permissions have been granted.
  ///
  /// On Android 12+ (API 31+): checks BLUETOOTH_CONNECT permission.
  /// On older Android: checks BLUETOOTH permission.
  ///
  /// This only checks - it doesn't show any dialog. Use
  /// [requestBluetoothPermissions] to request permissions.
  ///
  /// Returns `true` if permissions are granted.
  Future<bool> hasBluetoothPermissions() {
    return BluetoothScannerPlatform.instance.hasBluetoothPermissions();
  }

  /// Requests Bluetooth permissions from the user.
  ///
  /// Shows the system permission dialog. The future completes when
  /// the user grants or denies the permission.
  ///
  /// Returns `true` if permission was granted, `false` if denied.
  Future<bool> requestBluetoothPermissions() {
    return BluetoothScannerPlatform.instance.requestBluetoothPermissions();
  }

  /// Checks if Bluetooth is currently enabled (turned on).
  ///
  /// **Note:** On Android 12+, this requires BLUETOOTH_CONNECT permission.
  /// Call [hasBluetoothPermissions] first and request if needed.
  ///
  /// Returns `true` if Bluetooth is enabled.
  /// Throws [PlatformException] if permissions are missing.
  Future<bool> isBluetoothEnabled() {
    return BluetoothScannerPlatform.instance.isBluetoothEnabled();
  }

  /// Requests the user to enable Bluetooth.
  ///
  /// Shows a system dialog asking the user to turn on Bluetooth.
  /// The future completes when the user accepts or declines.
  ///
  /// Returns `true` if Bluetooth was enabled, `false` if user declined.
  Future<bool> enableBluetooth() {
    return BluetoothScannerPlatform.instance.enableBluetooth();
  }

  /// Gets the list of paired (bonded) Bluetooth devices.
  ///
  /// Requires:
  /// - Bluetooth permissions to be granted
  /// - Bluetooth to be enabled
  ///
  /// Returns a list of [BluetoothDevice] objects representing paired devices,
  /// or `null` if unable to retrieve.
  Future<List<BluetoothDevice>?> getPairedDevices() {
    return BluetoothScannerPlatform.instance.getPairedDevices();
  }
}
