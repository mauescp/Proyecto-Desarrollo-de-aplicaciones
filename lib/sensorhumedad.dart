import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'widgets/language_switch_button.dart';

class SensorHumedadScreen extends StatefulWidget {
  @override
  _SensorHumedadScreenState createState() => _SensorHumedadScreenState();
}

class _SensorHumedadScreenState extends State<SensorHumedadScreen> {
  double humidity = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _generateHumidityValue();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _generateHumidityValue();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateHumidityValue() {
    setState(() {
      humidity = Random().nextDouble() * 100;
    });
  }

  String getHumidityStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (humidity < 30) {
      return localizations.translate("dry_environment");
    } else if (humidity < 70) {
      return localizations.translate("moderate_humidity");
    } else {
      return localizations.translate("humid_environment");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("humidity_sensor")),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          LanguageSwitchButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop,
                size: 100,
                color: Colors.blue.shade800,
              ),
              SizedBox(height: 20),
              Text(
                '${humidity.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                getHumidityStatus(context),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black54),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateHumidityValue,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  localizations.translate("update"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}