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
  List<BluetoothDevice> _pairedDevices = [];
  final List<BluetoothDevice> _discoveredDevices = [];
  bool _isLoadingPaired = true;
  ScanEvent _lastScanEvent = ScanNotStarted();

  final _bluetoothScanner = BluetoothScanner();

  @override
  void initState() {
    super.initState();
    _loadPairedDevices();
  }

  Future<void> _loadPairedDevices() async {
    setState(() => _isLoadingPaired = true);
    try {
      final isSupported = await _bluetoothScanner.isBluetoothSupported();
      if (!isSupported || !mounted) return;

      var hasPermissions = await _bluetoothScanner.hasBluetoothPermissions();
      if (!hasPermissions) {
        hasPermissions = await _bluetoothScanner.requestBluetoothPermissions();
        if (!hasPermissions || !mounted) return;
      }

      var isEnabled = await _bluetoothScanner.isBluetoothEnabled();
      if (!isEnabled) {
        isEnabled = await _bluetoothScanner.enableBluetooth();
        if (!isEnabled || !mounted) return;
      }

      final devices = await _bluetoothScanner.getPairedDevices() ?? [];
      if (!mounted) return;
      setState(() {
        _pairedDevices = devices;
        _isLoadingPaired = false;
      });
    } on PlatformException {
      if (mounted) setState(() => _isLoadingPaired = false);
    } catch (_) {
      if (mounted) setState(() => _isLoadingPaired = false);
    }
  }

  Future<void> _startDiscovery() async {
    setState(() {
      _discoveredDevices.clear();
      _lastScanEvent = ScanStarted();
    });

    _bluetoothScanner.startDiscovery().listen((event) {
      if (!mounted) return;
      setState(() {
        _lastScanEvent = event;
        if (event is DeviceFound && !_discoveredDevices.contains(event.device)) {
          _discoveredDevices.add(event.device);
        }
      });
    });
  }

  Future<void> _stopDiscovery() async {
    await _bluetoothScanner.stopDiscovery();
    if (mounted) setState(() => _lastScanEvent = ScanFinished());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Bluetooth Scanner')),
        body: Column(
          children: [
            Expanded(
              child: _PairedDevicesSection(
                devices: _pairedDevices,
                isLoading: _isLoadingPaired,
                onRefresh: _loadPairedDevices,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _ScanSection(
                lastEvent: _lastScanEvent,
                devices: _discoveredDevices,
                onStart: _startDiscovery,
                onStop: _stopDiscovery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PairedDevicesSection extends StatelessWidget {
  const _PairedDevicesSection({
    required this.devices,
    required this.isLoading,
    required this.onRefresh,
  });

  final List<BluetoothDevice> devices;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: 'Paired Devices',
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : onRefresh,
          ),
        ),
        Expanded(child: _body()),
      ],
    );
  }

  Widget _body() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (devices.isEmpty) return const Center(child: Text('No paired devices found'));
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (_, index) => _DeviceTile(device: devices[index], icon: Icons.bluetooth),
    );
  }
}

class _ScanSection extends StatelessWidget {
  const _ScanSection({
    required this.lastEvent,
    required this.devices,
    required this.onStart,
    required this.onStop,
  });

  final ScanEvent lastEvent;
  final List<BluetoothDevice> devices;
  final VoidCallback onStart;
  final VoidCallback onStop;

  bool get _isScanning => lastEvent is ScanStarted || lastEvent is DeviceFound;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: 'Scan Results',
          trailing: TextButton(
            onPressed: _isScanning ? onStop : onStart,
            child: Text(_isScanning ? 'Stop' : 'Start Scan'),
          ),
        ),
        Expanded(child: _body()),
      ],
    );
  }

  Widget _body() {
    return switch (lastEvent) {
      ScanNotStarted() => const SizedBox.shrink(),
      ScanStarted() || DeviceFound() => const Center(child: CircularProgressIndicator()),
      ScanFinished() => devices.isEmpty
          ? const Center(child: Text('No devices found'))
          : _deviceList(),
      ScanError(:final message) => Center(child: Text(message)),
    };
  }

  Widget _deviceList() {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (_, index) => _DeviceTile(
        device: devices[index],
        icon: Icons.bluetooth_searching,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          trailing,
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.icon});

  final BluetoothDevice device;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(device.name ?? 'Unknown Device'),
      subtitle: Text(device.address ?? 'No MAC address'),
    );
  }
}
