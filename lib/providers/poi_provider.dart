import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poi.dart';

class PoiProvider with ChangeNotifier {
  String _city = '';
  List<PointOfInterest> _allPois = [];
  List<String> _categories = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;

  String get city => _city;
  List<PointOfInterest> get allPois => _allPois;
  List<String> get categories => _categories;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  List<PointOfInterest> get favorites => 
      _allPois.where((poi) => _favoriteIds.contains(poi.id)).toList();

  PoiProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/data/poi.json');
      final data = await json.decode(response);
      
      _city = data['city'] ?? 'Cidade';

      List<PointOfInterest> loadedPois = [];
      List<String> loadedCategories = [];

      for (var catJson in data['categories']) {
        String categoryName = catJson['name'];
        loadedCategories.add(categoryName);
        for (var poiJson in catJson['points']) {
          loadedPois.add(PointOfInterest.fromJson(poiJson, categoryName));
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

  List<PointOfInterest> getPoisByCategory(String category) {
    return _allPois.where((poi) => poi.category == category).toList();
  }
}
