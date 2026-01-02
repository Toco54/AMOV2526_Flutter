import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/POIProvider.dart';
import '../widgets/CategoryCard.dart';
import 'POIsListScreen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final poiProvider = Provider.of<POIProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.blue),
          onPressed: () {
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
      body: poiProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: poiProvider.categories.length,
              itemBuilder: (context, index) {
                final category = poiProvider.categories[index];
                return CategoryCard(
                  categoryName: category,
                  onTap: () {
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
