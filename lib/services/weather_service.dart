import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  // Coimbra coordinates
  static const double _lat = 40.2033;
  static const double _lon = -8.4103;

  Future<WeatherInfo?> fetchWeather() async {
    final url = Uri.parse('$_baseUrl?latitude=$_lat&longitude=$_lon&current_weather=true');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return WeatherInfo.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weather: $e');
      }
    }
    return null;
  }
}
