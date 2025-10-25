import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Presentation/providers.dart';
import 'dart:convert';


class BluetoothScreen extends ConsumerStatefulWidget {
  const BluetoothScreen({super.key});

  @override
  ConsumerState<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends ConsumerState<BluetoothScreen> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  final List<BluetoothDevice> _dispositivosDescubiertos = [];
  bool _buscando = false;

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBluetooth();
    });
  }


  Future<void> _initBluetooth() async {
    bool permisosOk = await _checkBluetoothPermissions();
    if (!permisosOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisos de Bluetooth no concedidos')),
      );
      return;
    }

    final bluetoothService = ref.read(bluetoothServiceProvider);
    await bluetoothService.enableBluetooth();
    final devices = await bluetoothService.getBondedDevices();
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
      final bluetoothService = ref.read(bluetoothServiceProvider);

      if (bluetoothService.isConnected &&
          bluetoothService.connectedDevice?.address == _selectedDevice!.address) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ya conectado a tu ${_selectedDevice!.name ?? _selectedDevice!.address}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      bool conectado = await bluetoothService.connectToDevice(_selectedDevice!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            conectado
                ? 'Conectado a tu ${_selectedDevice!.name ?? _selectedDevice!.address}'
                : 'No se pudo conectar',
          ),
          backgroundColor: conectado ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      if (conectado) {
        final now = TimeOfDay.now();
        final data = {
          "horaReloj": {
            "h": now.hour,
            "m": now.minute,
            "s": 0,
          }
        };
        final json = jsonEncode(data);
        bluetoothService.sendData("$json\n");
        print("Hora enviada al ESP32: ${now.format(context)}");
      }
    }
  }


  Future<void> _buscarDispositivosDisponibles() async {
  setState(() {
    _buscando = true;
    _dispositivosDescubiertos.clear();
  });

  final bluetoothService = ref.read(bluetoothServiceProvider);

  bluetoothService.startDiscovery().listen((result) {
    final device = result.device;

  final yaListado = _devices.any((d) => d.address == device.address) ||
                    _dispositivosDescubiertos.any((d) => d.address == device.address);

  if (!yaListado && device.name != null && device.name!.isNotEmpty) {
    setState(() {
      _dispositivosDescubiertos.add(device);
    });
  }
  }).onDone(() {
    setState(() {
      _buscando = false;
    });
  });
  }


  @override
  Widget build(BuildContext context) {
    final bluetoothService = ref.watch(bluetoothServiceProvider);
    final isConnected = bluetoothService.isConnected;

    final todosLosDispositivos = [
  ..._devices,
  ..._dispositivosDescubiertos.where(
    (d) => !_devices.any((e) => e.address == d.address),
  ) 
  ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectar Bluetooth'),
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
              items: todosLosDispositivos.map((device) {

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
                  isConnected ? 'Estado: Conectado' : 'Estado: Desconectado',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (_selectedDevice != null)
              Card(
                color: Theme.of(context).cardColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primaryContainer, 
                    width: 1,
                  ),
                  ),
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer, 
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _buscando ? null : _buscarDispositivosDisponibles,
              icon: const Icon(Icons.search),
              label: Text(_buscando ? "Buscando..." : "Buscar dispositivos disponibles"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_dispositivosDescubiertos.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Dispositivos disponibles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._dispositivosDescubiertos.map((device) {
                return ListTile(
                  leading: const Icon(Icons.bluetooth_searching),
                  title: Text(device.name!),
                  subtitle: Text(device.address),
                  onTap: () {
                    setState(() {
                      _selectedDevice = device;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Seleccionado: ${device.name ?? device.address}")),
                    );
                  },
                );
              }),
            ]
          ],
        ),
      ),
    );
  }
}



