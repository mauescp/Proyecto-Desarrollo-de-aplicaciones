import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  String _apiKey = "6ec6f140f1ecb199dca483203cae9530"; // Reemplaza con tu API key de OpenWeatherMap
  String _city = "Queretaro"; // Ciudad por defecto, puedes cambiarla

  WeatherData? get weatherData => _weatherData;

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$_city&units=metric&appid=$_apiKey'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _weatherData = WeatherData.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }
}