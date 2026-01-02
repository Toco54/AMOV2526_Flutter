import 'package:flutter/material.dart';
import '../services/DataManager.dart';
import '../widgets/POICard.dart';
import 'POIDetailsScreen.dart';

/// Ecrã que apresenta a lista de locais marcados como favoritos pelo utilizador.
class FavoritesScreen extends StatefulWidget {
  /// Callback para redirecionar o utilizador para o ecrã de categorias caso não existam favoritos.
  final VoidCallback? onGoToCategories;

  const FavoritesScreen({super.key, this.onGoToCategories});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  /// Instância do gestor de dados para manipulação do estado dos favoritos.
  final DataManager _dataManager = DataManager();

  @override
  Widget build(BuildContext context) {
    // Obtém a lista atualizada de favoritos em cada build.
    final favoritePois = _dataManager.getFavorites();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.blue),
          onPressed: () {
            // Fecha o MainScreen voltando para o HomeScreen inicial.
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        title: const Text(
          'Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: favoritePois.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                width: double.infinity, // Ocupa toda a largura disponível.
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7), // Cinza azulado muito claro.
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  // mainAxisSize: MainAxisSize.min faz com que a coluna ocupe apenas o espaço 
                  // necessário para os seus filhos, em vez de esticar para toda a altura.
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_border, size: 50, color: Color(0xFF9EA6B8)),
                    const SizedBox(height: 20),
                    const Text(
                      'Ainda não guardou nenhum favorito.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5E6D86),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: widget.onGoToCategories,
                      child: const Text(
                        'Categorias',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4B39EF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoritePois.length,
              itemBuilder: (context, index) {
                final poi = favoritePois[index];
                return POICard(
                  poi: poi,
                  isFavorite: true,
                  showCategory: true,
                  onToggleFavorite: () async {
                    // Remove dos favoritos e atualiza o estado local para refrescar a lista.
                    await _dataManager.toggleFavorite(poi.id);
                    setState(() {});
                  },
                  onTap: () {
                    // Abre detalhes usando o rootNavigator para sobrepor a barra de abas.
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => POIDetailsScreen(poi: poi),
                      ),
                    ).then((_) {
                      // Refresca a lista ao voltar (caso tenha sido removido dos favoritos no ecrã de detalhes).
                      setState(() {});
                    });
                  },
                );
              },
            ),
    );
  }
}
