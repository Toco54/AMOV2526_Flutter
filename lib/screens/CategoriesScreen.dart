import 'package:flutter/material.dart';
import '../services/DataManager.dart';
import '../widgets/CategoryCard.dart';
import 'POIsListScreen.dart';

/// Ecrã que apresenta a lista de categorias de pontos de interesse.
///
/// Atua como o nível superior da navegação no catálogo de locais.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Referência ao Singleton para acesso aos dados carregados.
    final dataManager = DataManager();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Cor de fundo suave (cinza claro)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.blue),
          onPressed: () {
            // Volta para o ecrã inicial saindo do fluxo de navegação aninhada.
            // rootNavigator: true força a procura do navegador de topo (MainScreen/App),
            // ignorando o navegador local da aba.
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        title: const Text(
          'Categorias',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: dataManager.isLoading
          ? const Center(child: CircularProgressIndicator())
          // ListView.builder é usado para listas longas ou dinâmicas.
          // PERFORMANCE: Apenas constrói os itens que estão visíveis no ecrã (lazy loading).
          : ListView.builder(
              padding: const EdgeInsets.all(20), // Espaçamento uniforme em todos os lados da lista.
              itemCount: dataManager.categories.length,
              itemBuilder: (context, index) {
                final category = dataManager.categories[index];
                return CategoryCard(
                  categoryName: category,
                  onTap: () {
                    // Navega para a lista de locais da categoria selecionada.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => POIsListScreen(category: category),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
