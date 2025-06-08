import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';


class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      if (_connection != null && _connection!.isConnected) {
        _connectedDevice = device;
        print('Conexión exitosa');
        return true;
      } else {
        print('La conexión falló ');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }



  void sendData(String message) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
      _connection!.output.allSent;
      print('Mensaje enviado: $message');
    } else {
      print('No hay conexión Bluetooth activa');
    }
  }
  
  bool isConnectedTo(BluetoothDevice device) {
    return _connection != null &&
          _connection!.isConnected &&
          _connectedDevice != null &&
          _connectedDevice!.address == device.address;
  }


  void disconnect() {
    _connection?.dispose();
    _connection = null;
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  Future<void> enableBluetooth() async {
    if (!(await _bluetooth.isEnabled ?? false)) {
      await _bluetooth.requestEnable();
    }
  }
}