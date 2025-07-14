import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'widgets/language_switch_button.dart';

class SensorProximidadScreen extends StatefulWidget {
  @override
  _SensorProximidadScreenState createState() => _SensorProximidadScreenState();
}

class _SensorProximidadScreenState extends State<SensorProximidadScreen> {
  double proximity = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _generateProximityValue();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _generateProximityValue();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateProximityValue() {
    setState(() {
      proximity = Random().nextDouble() * 10;
    });
  }

  String getProximityStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (proximity < 2) {
      return localizations.translate("very_close_object");
    } else if (proximity < 5) {
      return localizations.translate("moderate_distance_object");
    } else {
      return localizations.translate("no_close_objects");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("proximity_sensor")),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        actions: [
          LanguageSwitchButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sensors,
                size: 100,
                color: Colors.green.shade800,
              ),
              SizedBox(height: 20),
              Text(
                '${proximity.toStringAsFixed(2)} m',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                getProximityStatus(context),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black54),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateProximityValue,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.green.shade700,
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