import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_manager.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_switch_button.dart';

class BluetoothConfigScreen extends StatefulWidget {
  @override
  _BluetoothConfigScreenState createState() => _BluetoothConfigScreenState();
}

class _BluetoothConfigScreenState extends State<BluetoothConfigScreen> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    try {
      await _requestPermissions();
                                    if (mounted) {
        await _checkBluetoothStatus();
        _startScan();
      }
    } catch (e) {
      print('Error en inicialización: $e');
    }
  }

  Future<void> _requestPermissions() async {
                                  try {
      // Solicitar permisos de ubicación primero
      var locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
              content: Text(AppLocalizations.of(context).translate("location_permission_required")),
              duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
                                          ),
                                        );
        return;
      }

      // Solicitar permisos de Bluetooth
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);
      
      if (!allGranted && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
            content: Text(AppLocalizations.of(context).translate("bluetooth_permissions_required")),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
                                          ),
                                        );
        return;
                                      }

      // Verificar si el Bluetooth está activado
      bool bluetoothEnabled = await FlutterBluePlus.isAvailable;
      if (!bluetoothEnabled && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
            content: Text(AppLocalizations.of(context).translate("enable_bluetooth")),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
    } catch (e) {
      print('Error al solicitar permisos: $e');
                                  }
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      bool isAvailable = await _bluetoothManager.isBluetoothAvailable();
      if (!isAvailable && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate("bluetooth_not_available")),
            duration: Duration(seconds: 3),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
    } catch (e) {
      print('Error checking Bluetooth status: $e');
                                  }
  }

  void _startScan() async {
    if (_isScanning) return;
    try {
      setState(() => _isScanning = true);
      await _bluetoothManager.startScan();
    } catch (e) {
      print('Error en escaneo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
                          ),
                        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<String> _getDeviceName(BluetoothDevice device) async {
    try {
      if (device.platformName.isNotEmpty) {
        return device.platformName;
      }
      
      if (device.name.isNotEmpty) {
        return device.name;
      }
      
      if (device.advName.isNotEmpty) {
        return device.advName;
      }
      
      if (device.isConnected) {
        await device.discoverServices();
        if (device.platformName.isNotEmpty) {
          return device.platformName;
        }
      }
    } catch (e) {
      print('Error obteniendo nombre del dispositivo: $e');
    }
    
    return AppLocalizations.of(context).translate("unknown_device");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("bluetooth_config")),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          LanguageSwitchButton(),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(AppLocalizations.of(context).translate("scan_devices")),
              trailing: _isScanning
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.bluetooth_searching),
              onTap: _isScanning ? null : _startScan,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<BluetoothDevice>>(
              stream: _bluetoothManager.deviceStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).translate("no_devices_found"),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
  }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final device = snapshot.data![index];
                    return FutureBuilder<String>(
                      future: _getDeviceName(device),
                      initialData: device.platformName.isNotEmpty
                          ? device.platformName
                          : device.name.isNotEmpty
                              ? device.name
                              : AppLocalizations.of(context).translate("unknown_device"),
                      builder: (context, nameSnapshot) {
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.bluetooth, color: Colors.blue),
                            title: Text(
                              nameSnapshot.data ?? AppLocalizations.of(context).translate("unknown_device"),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(device.id.id),
                            trailing: StreamBuilder<BluetoothConnectionState>(
                              stream: device.connectionState,
                              initialData: BluetoothConnectionState.disconnected,
                              builder: (c, snapshot) {
                                bool isConnected = snapshot.data == BluetoothConnectionState.connected;
                                
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isConnected ? Colors.red : Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    isConnected
                                        ? AppLocalizations.of(context).translate("disconnect")
                                        : AppLocalizations.of(context).translate("connect"),
                                  ),
                                  onPressed: () async {
                                    try {
                                      if (isConnected) {
                                        await device.disconnect();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppLocalizations.of(context).translate("disconnected_successfully")),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
}
                                      } else {
                                        if (device.isConnected) {
                                          await _bluetoothManager.reconnectToSystemDevice(device);
                                        } else {
                                          await _bluetoothManager.connectToDevice(device);
                                        }
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppLocalizations.of(context).translate("connected_successfully")),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      }
                                    } catch (e) {
                                      print('Error en conexión: $e');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(AppLocalizations.of(context).translate("connection_failed")),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bluetoothManager.stopScan();
    super.dispose();
  }
}