import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  double temperature = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _generateTemperature();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _generateTemperature();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateTemperature() {
    setState(() {
      temperature = Random().nextDouble() * 40;
    });
  }

  String getTemperatureStatus() {
    if (temperature < 10) {
      return "Frío";
    } else if (temperature < 25) {
      return "Templado";
    } else {
      return "Caluroso";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperatura'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade100, Colors.orange.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat,
                size: 100,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                '${temperature.toStringAsFixed(2)} °C',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                getTemperatureStatus(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black54),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateTemperature,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Actualizar',
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