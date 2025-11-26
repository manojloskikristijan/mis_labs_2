import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/search_bar_widget.dart';
import 'recipe_detail_screen.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final String categoryName;

  const MealsByCategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  final MealApiService _apiService = MealApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Meal> _meals = [];
  List<Meal> _displayedMeals = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final meals = await _apiService.getMealsByCategory(widget.categoryName);
      setState(() {
        _meals = meals;
        _displayedMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _displayedMeals = _meals;
      });
    } else {
      _searchMeals(query);
    }
  }

  Future<void> _searchMeals(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final searchResults = await _apiService.searchMeals(query);
      setState(() {
        _displayedMeals = searchResults
            .where((meal) => _meals.any((m) => m.id == meal.id))
            .toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'Search meals...',
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_displayedMeals.isEmpty) {
      return Center(
        child: Text(_isSearching ? 'Searching...' : 'No meals found'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _displayedMeals.length,
      itemBuilder: (context, index) {
        final meal = _displayedMeals[index];
        return MealCard(
          meal: meal,
          onTap: () async {
            try {
              final recipe = await _apiService.getRecipeById(meal.id);
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading recipe: $e')),
              );
            }
          },
        );
      },
    );
  }
}

