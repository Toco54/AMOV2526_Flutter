import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/POI.dart';

/// Gestor central de dados da aplicação (Singleton).
///
/// Responsável por carregar dados estáticos (JSON), gerir o estado global
/// de POIs e categorias, e persistir as preferências do utilizador (favoritos).
/// Atua como a "Single Source of Truth" para os dados da aplicação.
class DataManager {
  // --- Padrão Singleton ---
  // Garante que apenas uma instância do DataManager exista durante o ciclo de vida da app.
  static final DataManager _instance = DataManager._internal();
  
  /// Acesso à instância única do DataManager.
  factory DataManager() => _instance;
  
  DataManager._internal();

  // --- Variáveis de Estado ---
  
  /// Nome da cidade carregada do JSON (metadado global).
  String _city = '';
  
  /// Lista mestre contendo todos os POIs de todas as categorias.
  /// Utilizada para buscas e filtragens globais.
  List<POI> _allPois = [];
  
  /// Lista de nomes de categorias disponíveis.
  /// Usada para popular a navegação por categorias.
  List<String> _categories = [];
  
  /// Flag de estado para indicar se o carregamento inicial está em progresso.
  /// Útil para exibir indicadores de carregamento na UI.
  bool _isLoading = true;

  /// Armazena os IDs dos POIs favoritos.
  /// Utiliza um Set para garantir unicidade e complexidade O(1) para lookups (contains).
  Set<int> _favorites = {};

  // --- Getters Públicos ---
  // Expõem o estado de forma apenas de leitura para proteger a integridade interna.
  
  String get city => _city;
  List<POI> get allPois => _allPois;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  /// Inicializa o serviço carregando dados do asset local e recuperando favoritos persistidos.
  ///
  /// Deve ser chamado no início da aplicação (ex: no main ou splash screen).
  Future<void> loadData() async {
    _isLoading = true;
    try {
      // Carrega o ficheiro JSON estático dos assets.
      final String response = await rootBundle.loadString('assets/data/poi.json');
      final data = await json.decode(response);
      
      _city = data['city'] ?? 'Cidade';

      List<POI> loadedPois = [];
      List<String> loadedCategories = [];

      // Processa a estrutura hierárquica do JSON (Categorias -> Pontos).
      // Flattening: Transforma a estrutura aninhada em listas planas para facilitar o uso.
      for (var catJson in data['categories']) {
        String categoryName = catJson['name'];
        loadedCategories.add(categoryName);
        
        // Itera sobre os pontos dentro de cada categoria.
        for (var poiJson in catJson['points']) {
          // Injeta o nome da categoria no objeto POI para referência reversa.
          loadedPois.add(POI.fromJson(poiJson, categoryName));
        }
      }

      // Atualiza o estado em memória.
      _allPois = loadedPois;
      _categories = loadedCategories;
      
      // Carrega os favoritos persistidos após ter os dados base prontos.
      await _loadFavorites();
    } catch (e) {
      // Tratamento básico de erro para depuração.
      if (kDebugMode) {
        print('Error loading POIs: $e');
      }
    } finally {
      // Garante que o estado de loading seja desativado mesmo em caso de erro.
      _isLoading = false;
    }
  }

  /// Recupera a lista de favoritos do armazenamento local (SharedPreferences).
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Recupera como lista de strings (limitação do SharedPreferences).
    final List<String>? favoritesList = prefs.getStringList('favorites');
    
    if (favoritesList != null) {
      // Converte e mapeia para o Set de inteiros em memória.
      _favorites = favoritesList.map((id) => int.parse(id)).toSet();
    }
  }

  /// Alterna o estado de favorito de um POI e persiste a mudança.
  ///
  /// [poiId] - O ID do POI a ser adicionado/removido como favorito.
  Future<void> toggleFavorite(int poiId) async {
    // Lógica de toggle: remove se existe, adiciona se não existe.
    if (_favorites.contains(poiId)) {
      _favorites.remove(poiId);
    } else {
      _favorites.add(poiId);
    }
    
    // Persiste a alteração imediatamente.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.map((id) => id.toString()).toList());
  }

  /// Verifica se um POI específico está marcado como favorito.
  ///
  /// [poiId] - O ID do POI.
  /// Returns: `true` se for favorito, `false` caso contrário.
  bool isFavorite(int poiId) {
    return _favorites.contains(poiId);
  }

  /// Filtra a lista global de POIs por categoria.
  ///
  /// [category] - O nome da categoria para filtrar.
  /// Returns: Lista de POIs pertencentes à categoria.
  List<POI> getPoisByCategory(String category) {
    return _allPois.where((poi) => poi.category == category).toList();
  }
  
  /// Retorna todos os POIs marcados como favoritos.
  ///
  /// Returns: Lista de POIs favoritos.
  List<POI> getFavorites() {
    // Filtra a lista mestra verificando a presença do ID no Set de favoritos.
    return _allPois.where((poi) => _favorites.contains(poi.id)).toList();
  }
}
