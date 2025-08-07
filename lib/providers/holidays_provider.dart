import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/holiday_model.dart';

class HolidaysProvider with ChangeNotifier {
  List<Holiday> _holidays = [];
  bool _isLoading = false;
  String _error = '';

  List<Holiday> get holidays => _holidays;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchHolidays() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://date.nager.at/api/v3/PublicHolidays/2025/MX'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> holidaysJson = json.decode(response.body);
        _holidays = holidaysJson.map((json) => Holiday.fromJson(json)).toList();
        
        // Ordenar las fechas por la más próxima
        _holidays.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
        
        // Filtrar solo las fechas futuras
        final now = DateTime.now();
        _holidays = _holidays.where((holiday) => 
          DateTime.parse(holiday.date).isAfter(now)
        ).toList();
      } else {
        _error = 'Error al cargar los días feriados';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}