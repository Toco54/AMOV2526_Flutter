import 'package:flutter/material.dart';

/// Cartão visual que representa uma categoria de Pontos de Interesse.
///
/// Exibe um ícone (emoji) e o nome da categoria, fornecendo uma área 
/// interativa para navegação.
class CategoryCard extends StatelessWidget {
  /// Nome da categoria a exibir.
  final String categoryName;
  /// Callback executado ao tocar no cartão.
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.onTap,
  });

  /// Determina o ícone visual (emoji) com base no nome da categoria.
  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Monumentos':
        return '🏰';
      case 'Museus':
        return '🖼️';
      case 'Gastronomia':
        return '🍽️';
      case 'Parques':
        return '🌲';
      default:
        return '📍';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Container: Widget versátil para posicionamento, pintura e dimensionamento.
    // Aqui define a estrutura base do cartão com margem e decoração.
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // BoxShadow: Adiciona profundidade visual ao elemento.
        // blurRadius define a suavidade da sombra; offset define a direção da "luz".
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        // InkWell: Adiciona interatividade "Material Design" com efeito visual de toque (ripple).
        // Necessita de um widget Material como ancestral para desenhar a animação.
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Row(
              children: [
                Text(
                  _getCategoryIcon(categoryName),
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 24),
                // Expanded: Widget que obriga o filho a preencher todo o espaço restante no eixo principal.
                // Essencial dentro de Rows/Columns para evitar erros de overflow e permitir texto longo.
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
