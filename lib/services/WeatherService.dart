import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/Weather.dart';

/// Serviço responsável pela comunicação com a API de meteorologia.
/// Encapsula a lógica de requisição HTTP, tratamento de erros e parsing da resposta.
class WeatherService {
  /// URL base da API Open-Meteo.
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  // Coordenadas fixas para Coimbra.
  static const double _lat = 40.2033;
  static const double _lon = -8.4103;

  /// Procura as informações meteorológicas atuais para as coordenadas configuradas.
  /// [returns]: Um objeto [WeatherInfo] se for bem-sucedido, ou `null` em caso de erro.
  Future<WeatherInfo?> fetchWeather() async {
    // Constrói o URL completo com parâmetros de query string.
    final url = Uri.parse('$_baseUrl?latitude=$_lat&longitude=$_lon&current_weather=true');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Descodifica o JSON e utiliza o factory do modelo para criar a instância.
        return WeatherInfo.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter meteorologia: $e');
      }
    }
    return null;
  }
}