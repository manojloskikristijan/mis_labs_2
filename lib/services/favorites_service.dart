import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final List<Meal> _favorites = [];
  bool _isInitialized = false;

  List<Meal> get favorites => List.unmodifiable(_favorites);

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadFavorites();
    _isInitialized = true;
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    _favorites.clear();
    for (final json in favoritesJson) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _favorites.add(Meal.fromJson(map));
      } catch (e) {
        debugPrint('Error loading favorite: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = _favorites
        .map((meal) => jsonEncode({
              'idMeal': meal.id,
              'strMeal': meal.name,
              'strMealThumb': meal.thumbnail,
            }))
        .toList();
    await prefs.setStringList('favorites', favoritesJson);
  }

  bool isFavorite(String mealId) {
    return _favorites.any((meal) => meal.id == mealId);
  }

  Future<void> toggleFavorite(Meal meal) async {
    if (isFavorite(meal.id)) {
      _favorites.removeWhere((m) => m.id == meal.id);
    } else {
      _favorites.add(meal);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> addFavorite(Meal meal) async {
    if (!isFavorite(meal.id)) {
      _favorites.add(meal);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String mealId) async {
    _favorites.removeWhere((meal) => meal.id == mealId);
    await _saveFavorites();
    notifyListeners();
  }
}
