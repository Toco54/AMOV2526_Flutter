class WeatherInfo {
  final double temperature;
  final int weatherCode;
  final String condition;
  final String icon;

  WeatherInfo({
    required this.temperature,
    required this.weatherCode,
    required this.condition,
    required this.icon,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'];
    final code = current['weathercode'];
    return WeatherInfo(
      temperature: current['temperature'],
      weatherCode: code,
      condition: _getConditionFromCode(code),
      icon: _getIconFromCode(code),
    );
  }

  static String _getConditionFromCode(int code) {
    if (code == 0) return 'Céu Limpo';
    if (code <= 3) return 'Parcialmente Nublado';
    if (code <= 48) return 'Nevoeiro';
    if (code <= 67) return 'Chuva';
    if (code <= 77) return 'Neve';
    if (code <= 82) return 'Aguaceiros';
    if (code <= 99) return 'Trovoada';
    return 'Desconhecido';
  }

  static String _getIconFromCode(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 99) return '⛈️';
    return '❓';
  }
}
