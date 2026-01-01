import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/poi_provider.dart';
import 'poi_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onGoToCategories;

  const FavoritesScreen({super.key, this.onGoToCategories});

  @override
  Widget build(BuildContext context) {
    final poiProvider = Provider.of<PoiProvider>(context);
    final favorites = poiProvider.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.blue),
          onPressed: () {
            // Pop the entire MainScreen to return to HomeScreen
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
      body: favorites.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7), // Light grey background
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
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
                      onPressed: onGoToCategories,
                      child: const Text(
                        'Categorias',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4B39EF), // Deep blue/purple
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
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final poi = favorites[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(poi.shortDescription),
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
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => poiProvider.toggleFavorite(poi.id),
                    ),
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