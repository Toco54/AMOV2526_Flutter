import 'package:flutter/material.dart';
import '../services/DataManager.dart';
import '../widgets/POICard.dart';
import 'POIDetailsScreen.dart';

class POIsListScreen extends StatefulWidget {
  final String category;

  const POIsListScreen({super.key, required this.category});

  @override
  State<POIsListScreen> createState() => _POIsListScreenState();
}

class _POIsListScreenState extends State<POIsListScreen> {
  final DataManager _dataManager = DataManager();

  @override
  Widget build(BuildContext context) {
    final pois = _dataManager.getPoisByCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: ListView.builder(
        itemCount: pois.length,
        itemBuilder: (context, index) {
          final poi = pois[index];
          final isFavorite = _dataManager.isFavorite(poi.id);
          
          return PoiCard(
            poi: poi,
            isFavorite: isFavorite,
            onToggleFavorite: () async {
              await _dataManager.toggleFavorite(poi.id);
              setState(() {}); // Update UI to reflect favorite change
            },
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => POIDetailsScreen(poi: poi),
                ),
              ).then((_) {
                // When returning from details, update UI (in case favorite changed there)
                setState(() {});
              });
            },
          );
        },
      ),
    );
  }
}