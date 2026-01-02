import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/POI.dart';

class POIProvider with ChangeNotifier {
  String _city = '';
  List<POI> _allPOIs = [];
  List<String> _categories = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;

  String get city => _city;
  List<POI> get allPOIs => _allPOIs;
  List<String> get categories => _categories;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  List<POI> get favorites => 
      _allPOIs.where((poi) => _favoriteIds.contains(poi.id)).toList();

  POIProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/data/poi.json');
      final data = await json.decode(response);
      
      _city = data['city'] ?? 'Cidade';

      List<POI> loadedPOIs = [];
      List<String> loadedCategories = [];

      for (var catJson in data['categories']) {
        String categoryName = catJson['name'];
        loadedCategories.add(categoryName);
        for (var poiJson in catJson['points']) {
          loadedPOIs.add(POI.fromJson(poiJson, categoryName));
        }
      }

      _allPOIs = loadedPOIs;
      _categories = loadedCategories;
      
      await _loadFavorites();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading POIs: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesList = prefs.getStringList('favorites');
    if (favoritesList != null) {
      _favoriteIds = favoritesList.map((id) => int.parse(id)).toSet();
    }
  }

  Future<void> toggleFavorite(int poiId) async {
    if (_favoriteIds.contains(poiId)) {
      _favoriteIds.remove(poiId);
    } else {
      _favoriteIds.add(poiId);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteIds.map((id) => id.toString()).toList());
    
    notifyListeners();
  }

  bool isFavorite(int poiId) {
    return _favoriteIds.contains(poiId);
  }

  List<POI> getPOIsByCategory(String category) {
    return _allPOIs.where((poi) => poi.category == category).toList();
  }
}