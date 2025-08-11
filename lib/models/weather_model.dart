class WeatherData {
  final double temperature;
  final String description;
  final String iconCode;
  final double humidity;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // Procesar la descripción para que coincida con nuestras claves de traducción
    String description = json['weather'][0]['description'].toString().toLowerCase();
    // Reemplazar espacios con guiones bajos para coincidir con las claves de traducción
    description = description.replaceAll(' ', '_');
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: description,
      iconCode: json['weather'][0]['icon'],
      humidity: (json['main']['humidity'] as num).toDouble(),
    );
  }
}