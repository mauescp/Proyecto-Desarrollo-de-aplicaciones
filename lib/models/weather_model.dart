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
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      humidity: (json['main']['humidity'] as num).toDouble(),
    );
  }
}