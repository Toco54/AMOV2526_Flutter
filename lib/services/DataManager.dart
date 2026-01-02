import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/POI.dart';

class DataManager {
  // Singleton pattern
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  String _city = '';
  List<POI> _allPois = [];
  List<String> _categories = [];
  bool _isLoading = true;

  // Simple Set for favorites
  Set<int> _favorites = {};

  String get city => _city;
  List<POI> get allPois => _allPois;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    try {
      final String response = await rootBundle.loadString('assets/data/poi.json');
      final data = await json.decode(response);
      
      _city = data['city'] ?? 'Cidade';

      List<POI> loadedPois = [];
      List<String> loadedCategories = [];

      for (var catJson in data['categories']) {
        String categoryName = catJson['name'];
        loadedCategories.add(categoryName);
        for (var poiJson in catJson['points']) {
          loadedPois.add(POI.fromJson(poiJson, categoryName));
        }
      }

      _allPois = loadedPois;
      _categories = loadedCategories;
      
      await _loadFavorites();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading POIs: $e');
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesList = prefs.getStringList('favorites');
    if (favoritesList != null) {
      _favorites = favoritesList.map((id) => int.parse(id)).toSet();
    }
  }

  Future<void> toggleFavorite(int poiId) async {
    if (_favorites.contains(poiId)) {
      _favorites.remove(poiId);
    } else {
      _favorites.add(poiId);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.map((id) => id.toString()).toList());
  }

  bool isFavorite(int poiId) {
    return _favorites.contains(poiId);
  }

  List<POI> getPoisByCategory(String category) {
    return _allPois.where((poi) => poi.category == category).toList();
  }
  
  List<POI> getFavorites() {
    return _allPois.where((poi) => _favorites.contains(poi.id)).toList();
  }
}
