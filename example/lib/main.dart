import 'package:bluetooth_scanner/bluetooth_scanner.dart';
import 'package:flutter/material.dart';
import 'dart:async';


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

  final _bluetoothScannerPlugin = BluetoothScanner();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices;
    try {
      await _bluetoothScannerPlugin.initBluetoothAdapter();

      devices = await _bluetoothScannerPlugin.getPairedDevices() ?? [];
    } catch (e) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Bluetooth scanner')),
        body: Center(
          child: ListView.builder(
            itemBuilder: (_, index) {
              final device = _devices[index];
              return ListTile(
                title: Text(device.name ?? 'Unknown'),
                subtitle: Text(device.address ?? 'No MAC address'),
                trailing: Text('RSSI: ${device.rssi ?? 'N/A'}'),
              );
            },
            itemCount: _devices.length,
          ),
        ),
      ),
    );
  }
}
