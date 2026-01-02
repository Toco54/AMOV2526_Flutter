import 'package:flutter/material.dart';
import '../models/POI.dart';
import '../services/DataManager.dart';

/// Ecrã de visualização detalhada de um Ponto de Interesse específico.
///
/// Exibe imagens, horários, preços e uma descrição completa do local.
class POIDetailsScreen extends StatefulWidget {
  /// O Ponto de Interesse cujos detalhes serão exibidos.
  final POI poi;

  const POIDetailsScreen({super.key, required this.poi});

  @override
  State<POIDetailsScreen> createState() => _POIDetailsScreenState();
}

class _POIDetailsScreenState extends State<POIDetailsScreen> {
  /// Instância do gestor de dados para verificar e alternar o estado de favorito.
  final DataManager _dataManager = DataManager();

  @override
  Widget build(BuildContext context) {
    // Verifica se o local atual está nos favoritos.
    final isFav = _dataManager.isFavorite(widget.poi.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poi.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? Colors.red : null,
            onPressed: () async {
              // Alterna o estado de favorito e atualiza a UI local (ícone do coração).
              await _dataManager.toggleFavorite(widget.poi.id);
              setState(() {});
            },
          ),
        ],
      ),
      // SingleChildScrollView permite que o conteúdo seja "scrollable" se exceder a altura do ecrã.
      // Previne erros de "pixel overflow" em ecrãs pequenos.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do Local (Asset)
            Image.asset(
              widget.poi.image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              // Fallback gracioso: Se a imagem não for encontrada, exibe um placeholder cinzento
              // em vez de "crashar" ou mostrar o ícone de erro padrão desformatado.
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.poi.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Linhas de Informação Rápida
                  _buildInfoRow(Icons.schedule, 'Horário', widget.poi.schedule),
                  _buildInfoRow(Icons.euro, 'Preço Médio', widget.poi.averagePrice),
                  _buildInfoRow(Icons.location_on, 'Localização aproximada', widget.poi.location),
                  // Divider cria uma linha horizontal ténue para separar secções logicamente.
                  const Divider(height: 32), // height aqui define o espaço total ocupado, não a espessura da linha.
                  const Text(
                    'Sobre',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.poi.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói uma linha de informação composta por ícone, etiqueta e valor.
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}