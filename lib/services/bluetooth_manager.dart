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
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw Exception('Bluetooth está apagado');
      }

      await stopScan();

      print('Iniciando escaneo Bluetooth...');
      
      // Obtener dispositivos ya conectados
      final connectedDevices = await FlutterBluePlus.connectedSystemDevices;
      if (connectedDevices.isNotEmpty) {
        print('Dispositivos conectados encontrados: ${connectedDevices.length}');
        _deviceController.add(connectedDevices);
      }

      // Iniciar escaneo
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      // Suscribirse a los resultados del escaneo
      FlutterBluePlus.scanResults.listen((results) {
        print('Resultados del escaneo: ${results.length} dispositivos');
        
        final devices = results.map((r) => r.device).toList();
        final allDevices = [...(connectedDevices), ...devices];
        
        // Filtrar dispositivos únicos
        final uniqueDevices = allDevices.toSet().toList();
        print('Dispositivos únicos encontrados: ${uniqueDevices.length}');
        _deviceController.add(uniqueDevices);
      }, onError: (error) {
        print('Error en el escaneo: $error');
      });
    } catch (e) {
      print('Error al iniciar escaneo: $e');
      throw e;
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print('Iniciando conexión a: ${device.remoteId}');
      await disconnect();

      if (!device.isConnected) {
        print('Intentando conectar...');
        await device.connect(
          timeout: const Duration(seconds: 30),
          autoConnect: false,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Tiempo de conexión agotado');
          },
        );
      }

      _connectedDevice = device;
      print('Dispositivo conectado, buscando servicios...');

      final services = await device.discoverServices();
      print('Servicios encontrados: ${services.length}');

      // UUIDs específicos de tu dispositivo
      const String serviceUuid = "FFE0";
      const String characteristicUuid = "FFE1";

      for (var service in services) {
        final serviceId = service.uuid.toString().toUpperCase();
        print('Analizando servicio: $serviceId');

        if (serviceId.contains(serviceUuid)) {
          for (var characteristic in service.characteristics) {
            final characteristicId = characteristic.uuid.toString().toUpperCase();
            print('Analizando característica: $characteristicId');

            if (characteristicId.contains(characteristicUuid)) {
              print('Característica encontrada, configurando...');
              _characteristic = characteristic;
              
              await characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen(
                (value) {
                  print('Datos recibidos: ${value.length} bytes');
                  _processData(value);
                },
                onError: (error) {
                  print('Error en notificaciones: $error');
                },
              );

              print('Configuración completada');
              return;
            }
          }
        }
      }

      throw Exception('No se encontró la característica adecuada');
    } catch (e) {
      print('Error en la conexión: $e');
        _connectedDevice = null;
        _characteristic = null;
      throw e;
  }
}

  Future<void> reconnectToSystemDevice(BluetoothDevice device) async {
    try {
      print('Reconectando a dispositivo del sistema: ${device.remoteId}');
      await connectToDevice(device);
    } catch (e) {
      print('Error en reconexión: $e');
      throw e;
    }
  }

  Future<void> stopScan() async {
    try {
      if (await FlutterBluePlus.isScanning.first) {
        print('Deteniendo escaneo...');
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      print('Error al detener escaneo: $e');
    }
  }

  void _processData(List<int> data) {
    try {
      final dataString = String.fromCharCodes(data);
      print('Datos recibidos: $dataString');
      
      final sensorData = <String, double>{};
      
      for (var part in dataString.split(',')) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          final value = double.tryParse(keyValue[1].trim());
          if (value != null) {
            sensorData[key] = value;
          }
        }
      }

      if (sensorData.isNotEmpty) {
        print('Datos procesados: $sensorData');
        _dataController.add(sensorData);
      }
    } catch (e) {
      print('Error procesando datos: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        print('Desconectando de: ${_connectedDevice!.remoteId}');
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
      final isOn = state == BluetoothAdapterState.on;
      print('Estado Bluetooth: ${isOn ? 'Encendido' : 'Apagado'}');
      return isOn;
    } catch (e) {
      print('Error verificando Bluetooth: $e');
      return false;
    }
  }

  void dispose() {
    print('Liberando recursos...');
    disconnect();
    _dataController.close();
    _deviceController.close();
  }
}