import 'package:flutter/material.dart';
import '../models/POI.dart';

/// Cartão visual para exibição resumida de um Ponto de Interesse numa lista.
///
/// Apresenta uma miniatura, nome, descrição curta e botão de favorito.
class POICard extends StatelessWidget {
  /// O modelo de dados do POI a exibir.
  final POI poi;
  /// Indica se o POI está atualmente marcado como favorito.
  final bool isFavorite;
  /// Controla a exibição da etiqueta da categoria no cartão.
  final bool showCategory;
  /// Callback disparado ao alternar o estado de favorito.
  final VoidCallback onToggleFavorite;
  /// Callback disparado ao tocar no cartão para ver detalhes.
  final VoidCallback onTap;

  const POICard({
    super.key,
    required this.poi,
    required this.isFavorite,
    this.showCategory = false,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Assegura que o conteúdo filho não transborda as bordas arredondadas do Card.
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        // ClipRRect força o arredondamento da imagem, que por padrão é quadrada.
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            poi.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover, // Preenche o quadrado cortando o excesso, mantendo a proporção.
            errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.image_not_supported, size: 60),
          ),
        ),
        title: Text(poi.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poi.shortDescription),
            // Lógica Condicional de Múltiplos Elementos:
            // Se 'showCategory' for verdadeiro, adicionamos dois widgets à lista desta Coluna:
            // 1. Um `SizedBox` (para dar um pequeno afastamento vertical).
            // 2. Um `Container` (que desenha a etiqueta visual com o nome da categoria).
            if (showCategory) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  poi.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: onToggleFavorite,
        ),
        onTap: onTap,
      ),
    );
  }
}