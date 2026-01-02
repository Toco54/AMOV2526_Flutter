import 'package:flutter/material.dart';
import '../models/POI.dart';
import '../services/DataManager.dart';

class POIDetailsScreen extends StatefulWidget {
  final POI poi;

  const POIDetailsScreen({super.key, required this.poi});

  @override
  State<POIDetailsScreen> createState() => _POIDetailsScreenState();
}

class _POIDetailsScreenState extends State<POIDetailsScreen> {
  final DataManager _dataManager = DataManager();

  @override
  Widget build(BuildContext context) {
    final isFav = _dataManager.isFavorite(widget.poi.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poi.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? Colors.red : null,
            onPressed: () async {
              await _dataManager.toggleFavorite(widget.poi.id);
              setState(() {}); // Update local UI (heart icon)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.poi.image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
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
                  _buildInfoRow(Icons.schedule, 'Horário', widget.poi.schedule),
                  _buildInfoRow(Icons.euro, 'Preço Médio', widget.poi.averagePrice),
                  _buildInfoRow(Icons.location_on, 'Localização aproximada', widget.poi.location),
                  const Divider(height: 32),
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