import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';
import '../models/recipe.dart';

class MealApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = (data['categories'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/filter.php?c=${Uri.encodeComponent(category)}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final meals = (data['meals'] as List)
              .map((json) => Meal.fromJson(json))
              .toList();
          return meals;
        }
        return [];
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      throw Exception('Error fetching meals: $e');
    }
  }

  Future<Recipe> getRecipeById(String id) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/lookup.php?i=${Uri.encodeComponent(id)}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && (data['meals'] as List).isNotEmpty) {
          return Recipe.fromJson(data['meals'][0]);
        }
        throw Exception('Recipe not found');
      } else {
        throw Exception('Failed to load recipe');
      }
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }

  Future<Recipe> getRandomRecipe() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/random.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && (data['meals'] as List).isNotEmpty) {
          return Recipe.fromJson(data['meals'][0]);
        }
        throw Exception('Random recipe not found');
      } else {
        throw Exception('Failed to load random recipe');
      }
    } catch (e) {
      throw Exception('Error fetching random recipe: $e');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/search.php?s=${Uri.encodeComponent(query)}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final meals = (data['meals'] as List)
              .map((json) => Meal.fromJson(json))
              .toList();
          return meals;
        }
        return [];
      } else {
        throw Exception('Failed to search meals');
      }
    } catch (e) {
      throw Exception('Error searching meals: $e');
    }
  }
}

