import 'package:flutter/material.dart';
import 'services/bluetooth_manager.dart';
import 'l10n/app_localizations.dart';
import 'models/sensor_reading.dart';
import 'screens/bluetooth_config_screen.dart';
class SensorHumedadScreen extends StatefulWidget {
  @override
  _SensorHumedadScreenState createState() => _SensorHumedadScreenState();
}

class _SensorHumedadScreenState extends State<SensorHumedadScreen> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  double currentHumidity = 0.0;
  List<SensorReading> readings = [];
  @override
  void initState() {
    super.initState();
    _setupBluetoothListener();
  }

  void _setupBluetoothListener() {
    _bluetoothManager.dataStream.listen((data) {
      setState(() {
        currentHumidity = data['humidity'] ?? 0.0;
        _addReading();
      });
    });
  }

  void _addReading() {
    final reading = SensorReading(
      sensorType: 'humidity',
      value: currentHumidity,
      unit: '%',
      timestamp: DateTime.now(),
    );
    
    setState(() {
      readings.add(reading);
      if (readings.length > 100) {
        readings.removeAt(0);
      }
    });
  }

  Color _getHumidityColor() {
    if (currentHumidity < 30) return Colors.orange;
    if (currentHumidity > 70) return Colors.blue;
    return Colors.green;
  }

  String _getHumidityStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (currentHumidity < 30) {
      return localizations.translate("dry_environment");
    } else if (currentHumidity > 70) {
      return localizations.translate("humid_environment");
    }
    return localizations.translate("moderate_humidity");
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("humidity_sensor")),
        backgroundColor: Colors.blue.shade700,
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
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildHumidityDisplay(),
            _buildReadingsHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityDisplay() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop,
            size: 80,
            color: _getHumidityColor(),
          ),
          SizedBox(height: 20),
          Text(
            '${currentHumidity.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getHumidityColor(),
            ),
          ),
          Text(
            _getHumidityStatus(context),
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
                    leading: Icon(Icons.water_drop),
                    title: Text('${reading.value.toStringAsFixed(1)}%'),
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
