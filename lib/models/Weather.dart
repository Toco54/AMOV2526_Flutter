/// Modelo de dados que representa as condições meteorológicas atuais.
///
/// Encapsula a temperatura, código meteorológico, descrição textual e ícone visual.
/// Utilizado para exibir o widget de clima no ecrã principal.
class WeatherInfo {
  /// Temperatura atual em graus Celsius.
  final double temperature;
  /// Código numérico da condição climática (padrão WMO).
  final int weatherCode;
  /// Descrição textual da condição (ex: "Céu Limpo").
  final String condition;
  /// Emoji ou ícone representando a condição.
  final String icon;

  /// Construtor padrão imutável.
  WeatherInfo({
    required this.temperature,
    required this.weatherCode,
    required this.condition,
    required this.icon,
  });

  /// Construtor que converte a resposta JSON da API Open-Meteo.
  ///
  /// [json] - O corpo da resposta da API desserializado..
  ///
  /// Returns: Uma instância de [WeatherInfo] processada.
  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    // Extrai o objeto 'current_weather' da resposta da API.
    final current = json['current_weather'];
    final code = current['weathercode'];
    
    // Constrói o objeto transformando o código numérico em representações legíveis (texto e ícone).
    return WeatherInfo(
      temperature: current['temperature'],
      weatherCode: code,
      condition: _getConditionFromCode(code), // Lógica de tradução isolada
      icon: _getIconFromCode(code),           // Lógica de representação visual isolada
    );
  }

  /// Converte o código WMO numa descrição textual.
  ///
  /// [code] - Código WMO numérico.
  /// Returns: String descritiva da condição.
  static String _getConditionFromCode(int code) {
    // Mapeamento simples de intervalos de códigos WMO para descrições.
    // A lógica usa 'early return' para clareza e eficiência.
    if (code == 0) return 'Céu Limpo';
    if (code <= 3) return 'Parcialmente Nublado';
    if (code <= 48) return 'Nevoeiro';
    if (code <= 67) return 'Chuva';
    if (code <= 77) return 'Neve';
    if (code <= 82) return 'Aguaceiros';
    if (code <= 99) return 'Trovoada';
    return 'Desconhecido'; // Fallback seguro
  }

  /// Converte o código WMO num ícone (Emoji).
  ///
  /// [code] - Código WMO numérico.
  /// Returns: String contendo o emoji correspondente.
  static String _getIconFromCode(int code) {
    // Similar a _getConditionFromCode, mapeia códigos para representações visuais rápidas.
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
