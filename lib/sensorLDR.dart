import 'package:flutter/material.dart';
import 'services/bluetooth_manager.dart';
import 'l10n/app_localizations.dart';
import 'models/sensor_reading.dart';
import 'screens/bluetooth_config_screen.dart';
class SensorLDRScreen extends StatefulWidget {
  @override
  _SensorLDRScreenState createState() => _SensorLDRScreenState();
}

class _SensorLDRScreenState extends State<SensorLDRScreen> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  double currentLight = 0.0;
  List<SensorReading> readings = [];
  @override
  void initState() {
    super.initState();
    _setupBluetoothListener();
  }

  void _setupBluetoothListener() {
    _bluetoothManager.dataStream.listen((data) {
      setState(() {
        currentLight = data['light'] ?? 0.0;
        _addReading();
      });
    });
  }

  void _addReading() {
    final reading = SensorReading(
      sensorType: 'light',
      value: currentLight,
      unit: 'lux',
      timestamp: DateTime.now(),
    );
    
    setState(() {
      readings.add(reading);
      if (readings.length > 100) {
        readings.removeAt(0);
      }
    });
  }

  Color _getLightColor() {
    if (currentLight < 300) return Colors.grey;
    if (currentLight > 750) return Colors.yellow;
    return Colors.amber;
  }

  String _getLightStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (currentLight < 300) {
      return localizations.translate("low_light");
    } else if (currentLight > 750) {
      return localizations.translate("high_light");
    }
    return localizations.translate("moderate_light");
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("light_sensor")),
        backgroundColor: Colors.amber.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BluetoothConfigScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.amber.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildLightDisplay(),
            _buildReadingsHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLightDisplay() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny,
            size: 80,
            color: _getLightColor(),
          ),
          SizedBox(height: 20),
          Text(
            '${currentLight.toStringAsFixed(1)} lux',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getLightColor(),
            ),
          ),
          Text(
            _getLightStatus(context),
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsHistory(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                AppLocalizations.of(context).translate("recent_readings"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: readings.length,
                itemBuilder: (context, index) {
                  final reading = readings[readings.length - 1 - index];
                  return ListTile(
                    leading: Icon(Icons.wb_sunny),
                    title: Text('${reading.value.toStringAsFixed(1)} lux'),
                    subtitle: Text(_formatDateTime(reading.timestamp)),
                    trailing: Icon(
                      Icons.circle,
                      color: reading.isInNormalRange() ? Colors.green : Colors.orange,
                      size: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  void dispose() {
    _bluetoothManager.disconnect();
    super.dispose();
  }
}
