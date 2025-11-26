class Recipe {
  final String id;
  final String name;
  final String thumbnail;
  final String instructions;
  final String youtubeLink;
  final List<Ingredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.instructions,
    required this.youtubeLink,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient,
          measure: measure ?? '',
        ));
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      youtubeLink: json['strYoutube'] ?? '',
      ingredients: ingredients,
    );
  }
}

class Ingredient {
  final String name;
  final String measure;

  Ingredient({
    required this.name,
    required this.measure,
  });
}

