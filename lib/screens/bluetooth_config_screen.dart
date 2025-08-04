import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_manager.dart';
import '../l10n/app_localizations.dart';
class BluetoothConfigScreen extends StatefulWidget {
  @override
  _BluetoothConfigScreenState createState() => _BluetoothConfigScreenState();
}

class _BluetoothConfigScreenState extends State<BluetoothConfigScreen> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  bool _isScanning = false;
  Map<String, String> _deviceNames = {};

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) {
      _checkBluetoothStatus();
    });
  }

  Future<void> _requestPermissions() async {
    try {
      // Solicitar permisos necesarios
      await Permission.location.request();
      await Permission.bluetooth.request();
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
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
          )
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
      if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
            content: Text(e.toString()),
            duration: Duration(seconds: 3),
          )
                                );
                              }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("bluetooth_config")),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).translate("scan_devices")),
            trailing: _isScanning
                ? CircularProgressIndicator()
                : Icon(Icons.bluetooth_searching),
            onTap: _isScanning ? null : _startScan,
          ),
          Expanded(
            child: StreamBuilder<List<BluetoothDevice>>(
              stream: _bluetoothManager.deviceStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context).translate("no_devices_found"))
                  );
  }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final device = snapshot.data![index];
                    return ListTile(
                      leading: Icon(Icons.bluetooth),
                      title: Text(
                        device.name.isNotEmpty 
                            ? device.name
                            : AppLocalizations.of(context).translate("unknown_device"),
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
                            ),
                            child: Text(
                              isConnected 
                                  ? AppLocalizations.of(context).translate("disconnect")
                                  : AppLocalizations.of(context).translate("connect")
                            ),
                            onPressed: () async {
                              try {
                                if (isConnected) {
                                  await device.disconnect();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context).translate("disconnected_successfully")),
                                      backgroundColor: Colors.green,
                                    )
                                  );
                                } else {
                                  await _bluetoothManager.connectToDevice(device);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context).translate("connected_successfully")),
                                      backgroundColor: Colors.green,
                                    )
                                  );
                                  Navigator.pop(context);
}
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context).translate("connection_failed")),
                                    backgroundColor: Colors.red,
                                  )
                                );
                              }
                            },
                          );
                        },
                      ),
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