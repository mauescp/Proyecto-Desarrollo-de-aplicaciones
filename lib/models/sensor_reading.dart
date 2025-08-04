class SensorReading {
  final String sensorType; // 'temperature', 'humidity', 'proximity', 'light'
  final double value;
  final String unit;
  final DateTime timestamp;

  SensorReading({
    required this.sensorType,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'sensorType': sensorType,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      sensorType: json['sensorType'] as String,
      value: json['value'] as double,
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Obtener la unidad correcta según el tipo de sensor
  static String getUnitForSensorType(String sensorType) {
    switch (sensorType) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'proximity':
        return 'cm';
      case 'light':
        return 'lux';
      default:
        return '';
    }
  }

  // Obtener el rango normal para cada tipo de sensor
  static Map<String, double> getNormalRange(String sensorType) {
    switch (sensorType) {
      case 'temperature':
        return {'min': 18.0, 'max': 25.0};
      case 'humidity':
        return {'min': 30.0, 'max': 60.0};
      case 'proximity':
        return {'min': 10.0, 'max': 100.0};
      case 'light':
        return {'min': 300.0, 'max': 750.0};
      default:
        return {'min': 0.0, 'max': 100.0};
    }
  }

  // Verificar si el valor está en el rango normal
  bool isInNormalRange() {
    final range = getNormalRange(sensorType);
    return value >= range['min']! && value <= range['max']!;
  }

  // Obtener una descripción del estado basada en el valor
  String getStatus() {
    if (!isInNormalRange()) {
      final range = getNormalRange(sensorType);
      if (value < range['min']!) {
        return 'Bajo';
      } else {
        return 'Alto';
      }
    }
    return 'Normal';
  }

  // Clonar la lectura con nuevos valores
  SensorReading copyWith({
    String? sensorType,
    double? value,
    String? unit,
    DateTime? timestamp,
  }) {
    return SensorReading(
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'SensorReading{sensorType: $sensorType, value: $value$unit, timestamp: $timestamp}';
  }

  // Comparar dos lecturas
  bool equals(SensorReading other) {
    return sensorType == other.sensorType &&
           value == other.value &&
           unit == other.unit &&
           timestamp == other.timestamp;
  }

  // Calcular la diferencia con otra lectura
  double getDifference(SensorReading other) {
    if (sensorType != other.sensorType) {
      throw ArgumentError('Cannot compare different sensor types');
    }
    return value - other.value;
  }

  // Verificar si la lectura es crítica (fuera de rango por un margen significativo)
  bool isCritical() {
    final range = getNormalRange(sensorType);
    final margin = (range['max']! - range['min']!) * 0.2; // 20% del rango

    return value < (range['min']! - margin) || 
           value > (range['max']! + margin);
  }

  // Obtener un color sugerido basado en el estado
  int getStatusColor() {
    if (isCritical()) {
      return 0xFFFF0000; // Rojo
    } else if (!isInNormalRange()) {
      return 0xFFFFAA00; // Naranja
    }
    return 0xFF00FF00; // Verde
  }
}