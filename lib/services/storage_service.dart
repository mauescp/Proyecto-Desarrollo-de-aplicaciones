import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sensor_reading.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final String _readingsKey = 'sensor_readings';
  
  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> saveReading(SensorReading reading) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> readings = prefs.getStringList(_readingsKey) ?? [];
    readings.add(json.encode(reading.toJson()));
    await prefs.setStringList(_readingsKey, readings);
  }

  Future<List<SensorReading>> getReadings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> readings = prefs.getStringList(_readingsKey) ?? [];
    return readings
        .map((str) => SensorReading.fromJson(json.decode(str)))
        .toList();
  }

  Future<void> clearReadings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_readingsKey);
  }
}