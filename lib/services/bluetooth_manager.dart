import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;

  final _dataController = StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get dataStream => _dataController.stream;

  final _deviceController = StreamController<List<BluetoothDevice>>.broadcast();
  Stream<List<BluetoothDevice>> get deviceStream => _deviceController.stream;

  bool get isConnected => _connectedDevice != null;

  Future<void> startScan() async {
    try {
      // Verificar si el Bluetooth está encendido
      if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
        throw Exception('Bluetooth está apagado');
      }

      // Detener cualquier escaneo previo
      await stopScan();

      // Iniciar nuevo escaneo
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      
      // Escuchar resultados del escaneo
      FlutterBluePlus.scanResults.listen((results) {
        final devices = results.map((r) => r.device).toList();
        _deviceController.add(devices);
      });
    } catch (e) {
      print('Error al escanear: $e');
      throw e;
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error al detener el escaneo: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Desconectar dispositivo actual si existe
      await disconnect();

      // Conectar al nuevo dispositivo
      await device.connect(timeout: Duration(seconds: 4));
      _connectedDevice = device;

      // Descubrir servicios
      List<BluetoothService> services = await device.discoverServices();
      
      // UUID del servicio y característica de tu dispositivo Arduino
      // Deberás reemplazar estos UUID con los de tu dispositivo
      String serviceUuid = "FFE0"; // Ejemplo de UUID
      String characteristicUuid = "FFE1"; // Ejemplo de UUID

      for (BluetoothService service in services) {
        if (service.uuid.toString().toUpperCase().contains(serviceUuid)) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase().contains(characteristicUuid)) {
              _characteristic = characteristic;

              // Suscribirse a las notificaciones
              await characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen((value) {
                _processData(value);
              });
              break;
      }
          }
        }
      }

      if (_characteristic == null) {
        throw Exception('No se encontró la característica adecuada');
      }
    } catch (e) {
      print('Error al conectar: $e');
      _connectedDevice = null;
      _characteristic = null;
      throw e;
  }
}

  void _processData(List<int> data) {
    try {
      // Convertir bytes a string
      String dataString = String.fromCharCodes(data);
      Map<String, double> sensorData = {};
      
      // Procesar datos en formato "temp:23.5,hum:45.2,light:500,prox:10"
      dataString.split(',').forEach((part) {
        var keyValue = part.split(':');
        if (keyValue.length == 2) {
          sensorData[keyValue[0].trim()] = double.tryParse(keyValue[1].trim()) ?? 0.0;
    }
      });

      if (sensorData.isNotEmpty) {
        _dataController.add(sensorData);
  }
    } catch (e) {
      print('Error procesando datos: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _characteristic = null;
  }
    } catch (e) {
      print('Error al desconectar: $e');
}
  }

  Future<bool> isBluetoothAvailable() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      print('Error verificando Bluetooth: $e');
      return false;
    }
  }

  void dispose() {
    disconnect();
    _dataController.close();
    _deviceController.close();
  }
}