import 'package:bluetooth_scanner/bluetooth_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<BluetoothDevice> _devices = [];
  String _status = 'Initializing...';
  bool _isLoading = true;

  final _bluetoothScanner = BluetoothScanner();

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  /// Demonstrates the proper flow for using Bluetooth:
  /// 1. Check if Bluetooth is supported
  /// 2. Check/request permissions
  /// 3. Check if Bluetooth is enabled, enable if needed
  /// 4. Use Bluetooth features (get paired devices)
  Future<void> _initBluetooth() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking Bluetooth support...';
    });

    try {
      // Step 1: Check if device has Bluetooth hardware
      final isSupported = await _bluetoothScanner.isBluetoothSupported();
      if (!isSupported) {
        _updateStatus('Bluetooth not supported on this device');
        return;
      }

      // Step 2: Check and request permissions
      _updateStatus('Checking permissions...');
      var hasPermissions = await _bluetoothScanner.hasBluetoothPermissions();
      if (!hasPermissions) {
        _updateStatus('Requesting permissions...');
        hasPermissions = await _bluetoothScanner.requestBluetoothPermissions();
        if (!hasPermissions) {
          _updateStatus('Bluetooth permissions denied');
          return;
        }
      }

      // Step 3: Check if Bluetooth is enabled
      _updateStatus('Checking if Bluetooth is enabled...');
      var isEnabled = await _bluetoothScanner.isBluetoothEnabled();
      if (!isEnabled) {
        _updateStatus('Enabling Bluetooth...');
        isEnabled = await _bluetoothScanner.enableBluetooth();
        if (!isEnabled) {
          _updateStatus('User declined to enable Bluetooth');
          return;
        }
      }

      // Step 4: Get paired devices
      _updateStatus('Getting paired devices...');
      final devices = await _bluetoothScanner.getPairedDevices() ?? [];

      if (!mounted) return;

      setState(() {
        _devices = devices;
        _status = 'Found ${devices.length} paired device(s)';
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      _updateStatus('Error: ${e.message}');
    } catch (e) {
      _updateStatus('Unexpected error: $e');
    }
  }

  void _updateStatus(String status) {
    if (!mounted) return;
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Scanner'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initBluetooth,
            ),
          ],
        ),
        body: Column(
          children: [
            // Status bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              width: double.infinity,
              child: Row(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(child: Text(_status)),
                ],
              ),
            ),
            // Device list
            Expanded(
              child: _devices.isEmpty
                  ? const Center(child: Text('No paired devices found'))
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (_, index) {
                        final device = _devices[index];
                        return ListTile(
                          leading: const Icon(Icons.bluetooth),
                          title: Text(device.name ?? 'Unknown Device'),
                          subtitle: Text(device.address ?? 'No MAC address'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
