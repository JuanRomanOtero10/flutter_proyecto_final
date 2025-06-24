import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

class BluetoothService extends ChangeNotifier {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      if (_connection != null && _connection!.isConnected) {
        _connectedDevice = device;
        _isConnected = true;
        notifyListeners(); // Notifica a la UI
        print('Conexión exitosa');

        // Escucha la desconexión
        _connection!.input?.listen(null).onDone(() {
          _isConnected = false;
          notifyListeners(); // Notifica desconexión
        });

        return true;
      } else {
        print('La conexión falló');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  void disconnect() {
    _connection?.dispose();
    _connection = null;
    _connectedDevice = null;
    _isConnected = false;
    notifyListeners();
  }

  void sendData(String message) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
    }
  }

  Future<void> enableBluetooth() async {
    if (!(await _bluetooth.isEnabled ?? false)) {
      await _bluetooth.requestEnable();
    }
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetooth.getBondedDevices();
  }
}
