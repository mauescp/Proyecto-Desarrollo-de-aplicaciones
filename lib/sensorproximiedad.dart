import 'package:flutter/material.dart';
import 'services/bluetooth_manager.dart';
import 'l10n/app_localizations.dart';
import 'models/sensor_reading.dart';
import 'screens/bluetooth_config_screen.dart';
class SensorProximidadScreen extends StatefulWidget {
  @override
  _SensorProximidadScreenState createState() => _SensorProximidadScreenState();
}

class _SensorProximidadScreenState extends State<SensorProximidadScreen> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  double currentProximity = 0.0;
  List<SensorReading> readings = [];
  @override
  void initState() {
    super.initState();
    _setupBluetoothListener();
  }

  void _setupBluetoothListener() {
    _bluetoothManager.dataStream.listen((data) {
      setState(() {
        currentProximity = data['proximity'] ?? 0.0;
        _addReading();
      });
    });
  }

  void _addReading() {
    final reading = SensorReading(
      sensorType: 'proximity',
      value: currentProximity,
      unit: 'cm',
      timestamp: DateTime.now(),
    );
    
    setState(() {
      readings.add(reading);
      if (readings.length > 100) {
        readings.removeAt(0);
      }
    });
  }

  Color _getProximityColor() {
    if (currentProximity < 10) return Colors.red;
    if (currentProximity < 30) return Colors.orange;
    return Colors.green;
  }

  String _getProximityStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (currentProximity < 10) {
      return localizations.translate("very_close_object");
    } else if (currentProximity < 30) {
      return localizations.translate("moderate_distance_object");
    }
    return localizations.translate("no_close_objects");
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("proximity_sensor")),
        backgroundColor: Colors.green.shade700,
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
            colors: [Colors.green.shade100, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildProximityDisplay(),
            _buildReadingsHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProximityDisplay() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sensors,
            size: 80,
            color: _getProximityColor(),
          ),
          SizedBox(height: 20),
          Text(
            '${currentProximity.toStringAsFixed(1)} cm',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getProximityColor(),
            ),
          ),
          Text(
            _getProximityStatus(context),
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
                    leading: Icon(Icons.sensors),
                    title: Text('${reading.value.toStringAsFixed(1)} cm'),
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
