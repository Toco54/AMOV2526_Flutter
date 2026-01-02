import 'package:flutter/material.dart';
import 'services/DataManager.dart';
import 'screens/HomeScreen.dart';

/// Ponto de entrada principal da aplicação.
/// Configura o ambiente inicial, carrega os dados e inicia o Flutter.
void main() async {
  // Garante inicialização das bindings do Flutter antes de operações assíncronas.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialização prévia dos dados para garantir integridade no arranque.
  await DataManager().loadData();
  runApp(const MyApp());
}

/// Widget raiz da aplicação que define o tema global e o ecrã inicial.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guia de Coimbra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}