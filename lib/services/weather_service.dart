import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../api_key.dart';

class WeatherService {
  static const String _apiKey = openWeatherApiKey;
  static const String _baseUrl = 'api.openweathermap.org';

  Future<WeatherModel> getWeather(String cityName) async {
    final weatherUri = Uri.https(_baseUrl, '/data/2.5/weather', {
      'q': cityName,
      'appid': _apiKey,
      'units': 'metric'
    });

    final weatherResponse = await http.get(weatherUri);

    if (weatherResponse.statusCode != 200) {
      throw Exception('Failed to load weather data: Status ${weatherResponse.statusCode}.');
    }

    final weatherJson = jsonDecode(weatherResponse.body);

    final forecastUri = Uri.https(_baseUrl, '/data/2.5/forecast', {
      'q': cityName,
      'appid': _apiKey,
      'units': 'metric'
    });

    final forecastResponse = await http.get(forecastUri);

    List<ForecastModel> next3Days = [];
    if (forecastResponse.statusCode == 200) {
      final forecastJson = jsonDecode(forecastResponse.body);
      final List<dynamic> list = forecastJson['list'];
      
      String? lastAddedDay;

      // Extract one reading for each unique day exactly, effectively catching Today, Tomorrow, Day 3
      for (var item in list) {
        final forecast = ForecastModel.fromJson(item);
        final dayString = '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';
        
        // Take the very first JSON reading for mapping each unique day (including today!)
        if (dayString != lastAddedDay) {
          next3Days.add(forecast);
          lastAddedDay = dayString;
        }

        if (next3Days.length >= 3) break;
      }
    }

    return WeatherModel.fromJson(weatherJson, forecasts: next3Days);
  }
}
