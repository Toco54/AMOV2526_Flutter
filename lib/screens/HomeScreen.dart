import 'dart:async';
import 'package:flutter/material.dart';
import '../services/DataManager.dart';
import '../services/WeatherService.dart';
import '../models/Weather.dart';
import 'MainScreen.dart';

/// Ecrã de boas-vindas e introdução da aplicação.
///
/// Apresenta uma imagem de fundo apelativa, o nome da cidade e informações 
/// meteorológicas em tempo real.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Informação meteorológica atual processada do serviço.
  WeatherInfo? _weather;
  /// Estado que controla a visibilidade do indicador de carregamento.
  bool _loadingWeather = true;
  /// Instância do gestor de dados para obter informações globais (ex: nome da cidade).
  final DataManager _dataManager = DataManager();
  /// Temporizador para atualizar o clima em intervalos regulares.
  Timer? _weatherTimer;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    // Atualiza a meteorologia a cada 15 minutos para manter os dados frescos.
    _weatherTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _fetchWeather();
    });
  }

  @override
  void dispose() {
    // Garante o cancelamento do timer para evitar fugas de memória.
    _weatherTimer?.cancel();
    super.dispose();
  }

  /// Obtém os dados meteorológicos através do [WeatherService].
  Future<void> _fetchWeather() async {
    final weather = await WeatherService().fetchWeather();
    if (mounted) {
      setState(() {
        _weather = weather;
        _loadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack permite a sobreposição de elementos no eixo Z (fundo -> gradiente -> conteúdo).
      body: Stack(
        children: [
          // Imagem de Fundo (Asset local)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/coimbra_home.jpg'),
                fit: BoxFit.cover, // Garante que a imagem preencha todo o ecrã sem distorção.
              ),
            ),
          ),
          // Sobreposição de Gradiente para legibilidade do texto
          // UX: Escurece a imagem progressivamente para garantir contraste suficiente para o texto branco.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          // Conteúdo principal
          // SafeArea: Protege o conteúdo de interrupções físicas do hardware (notches, barras de estado).
          // Garante que o texto e botões não fiquem "cortados" em dispositivos modernos.
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dataManager.city.isNotEmpty ? _dataManager.city : 'Carregando...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)], // Sombra suave para destacar do fundo complexo.
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildWeatherSection(),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ).copyWith(
                      // Gestão de estado visual do botão:
                      // Aumenta a elevação (sombra) quando o rato passa por cima (Desktop/Web) ou é pressionado.
                      elevation: WidgetStateProperty.resolveWith<double>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) return 2; // "Afunda" ao clicar
                          if (states.contains(WidgetState.hovered)) return 12; // "Levanta" ao passar o rato
                          return 8; // Estado repouso
                        },
                      ),
                    ),
                    child: const Text(
                      'Descobrir Cidade',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a secção visual da meteorologia.
  Widget _buildWeatherSection() {
    if (_loadingWeather) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    if (_weather == null) {
      return const Text(
        'Clima indisponível',
        style: TextStyle(color: Colors.white),
      );
    }
    // Container: Aqui usado para criar uma "caixa" semi-transparente que agrupa o clima.
    // borderRadius e padding ajudam na organização visual e estética.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${_weather!.icon} ${_weather!.temperature}°C',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            _weather!.condition,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
