import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'widgets/language_switch_button.dart';

class SensorLDRScreen extends StatefulWidget {
  @override
  _SensorLDRScreenState createState() => _SensorLDRScreenState();
}

class _SensorLDRScreenState extends State<SensorLDRScreen> {
  double ldrValue = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _generateLDRValue();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _generateLDRValue();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateLDRValue() {
    setState(() {
      ldrValue = Random().nextDouble() * 100;
    });
  }

  String getLDRStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (ldrValue < 30) {
      return localizations.translate("low_light");
    } else if (ldrValue < 70) {
      return localizations.translate("moderate_light");
    } else {
      return localizations.translate("high_light");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("light_sensor")),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade700,
        actions: [
          LanguageSwitchButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade100, Colors.orange.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny,
                size: 100,
                color: Colors.yellow.shade800,
              ),
              SizedBox(height: 20),
              Text(
                '${ldrValue.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                getLDRStatus(context),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black54),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateLDRValue,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.amber.shade700,
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