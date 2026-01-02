import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/POIProvider.dart';
import '../widgets/POICard.dart';
import 'POIDetailsScreen.dart';

class POIsListScreen extends StatelessWidget {
  final String category;

  const POIsListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final poiProvider = Provider.of<POIProvider>(context);
    final pois = poiProvider.getPOIsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: pois.length,
        itemBuilder: (context, index) {
          final poi = pois[index];
          return PoiCard(
            poi: poi,
            isFavorite: poiProvider.isFavorite(poi.id),
            onToggleFavorite: () => poiProvider.toggleFavorite(poi.id),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => POIDetailsScreen(poi: poi),
                ),
              );
            },
          );
        },
      ),
    );
  }
}