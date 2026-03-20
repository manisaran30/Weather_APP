class ForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String mainCondition;

  ForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.mainCondition,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      mainCondition: json['weather'][0]['main'] ?? '',
    );
  }
}

class WeatherModel {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final String description;
  final List<ForecastModel>? forecasts;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.description,
    this.forecasts,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, {List<ForecastModel>? forecasts}) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      mainCondition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      forecasts: forecasts,
    );
  }
}
