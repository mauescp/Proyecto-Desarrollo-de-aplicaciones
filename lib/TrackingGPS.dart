import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RandomCoordinatesScreen extends StatefulWidget {
  @override
  _RandomCoordinatesScreenState createState() => _RandomCoordinatesScreenState();
}

class _RandomCoordinatesScreenState extends State<RandomCoordinatesScreen> {
  double latitude = 0.0;
  double longitude = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _generateCoordinates();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _generateCoordinates();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateCoordinates() {
    setState(() {
      latitude = Random().nextDouble() * 180 - 90; // Rango: -90 a 90
      longitude = Random().nextDouble() * 360 - 180; // Rango: -180 a 180
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordenadas Aleatorias'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Latitud: ${latitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Longitud: ${longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateCoordinates,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Generar Ahora',
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