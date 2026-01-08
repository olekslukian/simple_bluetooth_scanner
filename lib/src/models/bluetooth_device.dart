class BluetoothDevice {
  const BluetoothDevice({
    required this.name,
    required this.alias,
    required this.address,
    required this.rssi,
  });

  final String? name;
  final String? alias;
  final String? address;
  final int? rssi;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BluetoothDevice &&
        runtimeType == other.runtimeType &&
        other.name == name &&
        other.alias == alias &&
        other.address == address &&
        other.rssi == rssi;
  }

  @override
  int get hashCode => Object.hash(name, alias, address, rssi);

  @override
  String toString() =>
      'BluetoothDevice(name: $name, alias: $alias, address: $address, rssi: $rssi)';

  factory BluetoothDevice.fromMap(Map<String, dynamic> json) {
    return BluetoothDevice(
      name: json['name'] as String?,
      alias: json['alias'] as String?,
      address: json['address'] as String?,
      rssi: json['rssi'] as int?,
    );
  }
}
