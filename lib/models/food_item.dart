class FoodItem {
  final String id;
  final String name;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;
  final String baseUnit;

  FoodItem({
    required this.id,
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.baseUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'calories': calories,
      'baseUnit': baseUnit,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      baseUnit: json['baseUnit'],
    );
  }
}