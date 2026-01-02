import 'package:flutter/material.dart';
import 'CategoriesScreen.dart';
import 'FavoritesScreen.dart';

/// Ecrã principal que gere a navegação por abas (Bottom Navigation).
///
/// Implementa um padrão de navegação aninhada (Nested Navigation) para manter o estado
/// de cada aba independentemente.
class MainScreen extends StatefulWidget {
  /// Índice inicial opcional para abrir a aplicação numa aba específica.
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Índice da aba atualmente selecionada.
  late int _selectedIndex;

  /// Chaves globais para os navegadores de cada aba.
  /// Essencial para permitir navegação independente dentro de cada secção.
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    // Inicializa o estado com o índice vindo do widget.
    _selectedIndex = widget.initialIndex;
  }

  /// Processa o toque num item da barra de navegação.
  /// Se o utilizador tocar na aba ativa, volta ao início da pilha dessa aba.
  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Força a navegação para a aba de categorias (índice 0).
  void _goToCategories() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // PopScope gere o comportamento do botão "Retroceder" do sistema.
    // Interceção crítica para evitar que a app feche acidentalmente quando há histórico nas abas.
    return PopScope(
      canPop: false, // Desativa o comportamento padrão de fechar a atividade.
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // Tenta retroceder no navegador da aba ativa.
        final NavigatorState? currentNavigator = _navigatorKeys[_selectedIndex]?.currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
          return;
        }

        // Se estiver noutra aba, volta primeiro para a aba inicial (Categorias).
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }

        // Se estiver na aba inicial (Categorias) e sem histórico interno,
        // fecha o ecrã principal (MainScreen) e regressa ao menu inicial (HomeScreen).
        if (context.mounted) {
           Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        // IndexedStack mantém o estado de todos os filhos, mas apenas exibe um.
        // OTIMIZAÇÃO: Ao contrário de um switch case simples, isto mantém os Widgets
        // "vivos" na árvore, preservando a posição de scroll e dados de formulário ao trocar de aba.
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Aba 0: Navegação aninhada para Categorias.
            // Cria um novo Navigator independente do root, permitindo fluxo "dentro" da aba.
            Navigator(
              key: _navigatorKeys[0],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                );
              },
            ),
            // Aba 1: Navegação aninhada para Favoritos
            Navigator(
              key: _navigatorKeys[1],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => FavoritesScreen(
                    onGoToCategories: _goToCategories,
                  ),
                );
              },
            ),
          ],
        ),
        // BottomNavigationBar: Componente de navegação persistente no fundo do ecrã.
        // currentIndex indica qual a aba ativa; onTap gere a lógica de troca de estado.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categorias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }
}