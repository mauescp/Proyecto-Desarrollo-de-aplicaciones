import 'package:appgestion/temperatura.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'widgets/language_switch_button.dart';
import 'sensorhumedad.dart';
import 'sensorproximiedad.dart';
import 'sensorLDR.dart';

class SensoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("sensors")),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          LanguageSwitchButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate("available_sensors"),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildSensorCard(
                    context,
                    "humidity_sensor",
                    Icons.water_drop,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SensorHumedadScreen()),
                    ),
                  ),
                  _buildSensorCard(
                    context,
                    "proximity_sensor",
                    Icons.sensors,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SensorProximidadScreen()),
                    ),
                  ),
                  _buildSensorCard(
                    context,
                    "light_sensor",
                    Icons.wb_sunny,
                    Colors.amber,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SensorLDRScreen()),
                    ),
                  ),
                  _buildSensorCard(
                    context,
                    "temperature_sensor",
                    Icons.thermostat,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TemperatureScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context,
    String nameKey,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final localizations = AppLocalizations.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              SizedBox(height: 16),
              Text(
                localizations.translate(nameKey),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}