import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/poi_provider.dart';
import 'poi_detail_screen.dart';

class PoisListScreen extends StatelessWidget {
  final String category;

  const PoisListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final poiProvider = Provider.of<PoiProvider>(context);
    final pois = poiProvider.getPoisByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: pois.length,
        itemBuilder: (context, index) {
          final poi = pois[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  poi.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.image_not_supported, size: 60),
                ),
              ),
              title: Text(poi.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(poi.shortDescription),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => PoiDetailScreen(poi: poi),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
