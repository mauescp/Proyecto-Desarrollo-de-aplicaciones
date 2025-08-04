import 'package:flutter/material.dart';
import 'services/bluetooth_manager.dart';
import 'l10n/app_localizations.dart';
import 'models/sensor_reading.dart';
import 'screens/bluetooth_config_screen.dart';

class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  double currentTemperature = 0.0;
  List<SensorReading> readings = [];
  bool isConnected = false;
  @override
  void initState() {
    super.initState();
    _setupBluetoothListener();
  }

  void _setupBluetoothListener() {
    _bluetoothManager.dataStream.listen((data) {
      setState(() {
        currentTemperature = data['temperature'] ?? 0.0;
        _addReading();
      });
    });
  }

  void _addReading() {
    final reading = SensorReading(
      sensorType: 'temperature',
      value: currentTemperature,
      unit: '°C',
      timestamp: DateTime.now(),
    );
    
    setState(() {
      readings.add(reading);
      if (readings.length > 100) { // Mantener solo las últimas 100 lecturas
        readings.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("temperature_sensor")),
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
      body: Column(
        children: [
          _buildTemperatureDisplay(context),
          _buildReadingsHistory(context),
        ],
      ),
    );
  }

  Widget _buildTemperatureDisplay(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.thermostat,
            size: 80,
            color: _getTemperatureColor(),
          ),
          SizedBox(height: 20),
          Text(
            '${currentTemperature.toStringAsFixed(1)}°C',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getTemperatureColor(),
            ),
          ),
          Text(
            _getTemperatureStatus(context),
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
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.builder(
          itemCount: readings.length,
          itemBuilder: (context, index) {
            final reading = readings[readings.length - 1 - index];
            return ListTile(
              leading: Icon(Icons.thermostat),
              title: Text('${reading.value.toStringAsFixed(1)}°C'),
              subtitle: Text(_formatDateTime(reading.timestamp)),
              trailing: Icon(
                _getTemperatureIcon(reading.value),
                color: _getTemperatureColorForValue(reading.value),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getTemperatureColor() {
    if (currentTemperature < 18) return Colors.blue;
    if (currentTemperature > 30) return Colors.red;
    return Colors.green;
  }

  String _getTemperatureStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (currentTemperature < 18) {
      return localizations.translate("low_temperature");
    } else if (currentTemperature > 30) {
      return localizations.translate("high_temperature");
    }
    return localizations.translate("normal_temperature");
  }

  IconData _getTemperatureIcon(double temp) {
    if (temp < 18) return Icons.ac_unit;
    if (temp > 30) return Icons.whatshot;
    return Icons.thermostat;
  }

  Color _getTemperatureColorForValue(double temp) {
    if (temp < 18) return Colors.blue;
    if (temp > 30) return Colors.red;
    return Colors.green;
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
