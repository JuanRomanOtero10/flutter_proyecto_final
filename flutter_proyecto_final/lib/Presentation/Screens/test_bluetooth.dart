import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_proyecto_final/Core/bluethoot_service.dart';
import 'package:permission_handler/permission_handler.dart';

class TestBluetoothScreen extends StatefulWidget {
  const TestBluetoothScreen({super.key});

  @override
  State<TestBluetoothScreen> createState() => _TestBluetoothScreenState();
}

class _TestBluetoothScreenState extends State<TestBluetoothScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    bool permisosOk = await _checkBluetoothPermissions();
    if (!permisosOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisos de Bluetooth no concedidos')),
      );
      return;
    }

    await _bluetoothService.enableBluetooth();
    final devices = await _bluetoothService.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  Future<bool> _checkBluetoothPermissions() async {
    final statusScan = await Permission.bluetoothScan.status;
    final statusConnect = await Permission.bluetoothConnect.status;
    final statusLocation = await Permission.locationWhenInUse.status;

    if (!statusScan.isGranted) await Permission.bluetoothScan.request();
    if (!statusConnect.isGranted) await Permission.bluetoothConnect.request();
    if (!statusLocation.isGranted) await Permission.locationWhenInUse.request();

    return await Permission.bluetoothScan.isGranted &&
           await Permission.bluetoothConnect.isGranted &&
           await Permission.locationWhenInUse.isGranted;
  }

  void _connect() async {
    if (_selectedDevice != null) {
      if (_bluetoothService.isConnectedTo(_selectedDevice!)) {
        setState(() {
          _isConnected = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ya conectado a ${_selectedDevice!.name ?? _selectedDevice!.address}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      bool conectado = await _bluetoothService.connectToDevice(_selectedDevice!);

      setState(() {
        _isConnected = conectado;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            conectado
                ? 'Conectado a ${_selectedDevice!.name ?? _selectedDevice!.address}'
                : 'No se pudo conectar',
          ),
          backgroundColor: conectado ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }




  void _sendMessage() {
    _bluetoothService.sendData("Hola ESP32\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba Bluetooth'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Seleccioná un dispositivo emparejado:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BluetoothDevice>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                labelText: 'Dispositivo Bluetooth',
              ),
              value: _selectedDevice,
              onChanged: (device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? device.address),
                );
              }).toList(),
            ),
            if (_selectedDevice != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _isConnected
                      ? 'Estado: Conectado'
                      : 'Estado: Desconectado',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 24),
            if (_selectedDevice != null)
              Card(
                color: Colors.blue.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.bluetooth, color: Colors.blue),
                  title: Text(_selectedDevice!.name ?? 'Sin nombre'),
                  subtitle: Text(_selectedDevice!.address),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _connect,
              icon: const Icon(Icons.link),
              label: const Text("Conectar"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              label: const Text("Enviar 'Hola ESP32'"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 154, 225, 238),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


