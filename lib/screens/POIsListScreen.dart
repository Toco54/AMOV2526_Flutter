import 'package:flutter/material.dart';
import '../services/DataManager.dart';
import '../widgets/POICard.dart';
import 'POIDetailsScreen.dart';

/// Ecrã que apresenta a lista de pontos de interesse de uma categoria específica.
class POIsListScreen extends StatefulWidget {
  /// Nome da categoria a filtrar.
  final String category;

  const POIsListScreen({super.key, required this.category});

  @override
  State<POIsListScreen> createState() => _POIsListScreenState();
}

class _POIsListScreenState extends State<POIsListScreen> {
  /// Instância do gestor de dados para filtragem por categoria.
  final DataManager _dataManager = DataManager();

  @override
  Widget build(BuildContext context) {
    // Filtra os POIs pertencentes à categoria deste ecrã.
    final pois = _dataManager.getPoisByCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      // ListView.builder cria uma lista de rolagem eficiente.
      // itemCount define o número total de itens; itemBuilder constrói cada item sob demanda.
      body: ListView.builder(
        itemCount: pois.length,
        itemBuilder: (context, index) {
          final poi = pois[index];
          final isFavorite = _dataManager.isFavorite(poi.id);
          
          return POICard(
            poi: poi,
            isFavorite: isFavorite,
            onToggleFavorite: () async {
              // Alterna o estado de favorito e atualiza a lista.
              await _dataManager.toggleFavorite(poi.id);
              setState(() {});
            },
            onTap: () {
              // Navega para os detalhes. Usa o rootNavigator para esconder as abas durante os detalhes.
              // Ao empilhar no navegador de raiz, o ecrã de detalhes cobrirá a BottomNavigationBar.
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => POIDetailsScreen(poi: poi),
                ),
              ).then((_) {
                // Refresca o ecrã ao voltar caso o estado de favorito tenha mudado nos detalhes.
                setState(() {});
              });
            },
          );
        },
      ),
    );
  }
}