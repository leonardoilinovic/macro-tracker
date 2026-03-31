import 'food_item.dart';

class DailyFoodEntry {
  final String id;
  final FoodItem food;
  final double amount;
  final String date;

  final double protein;
  final double carbs;
  final double fat;
  final double calories;

  final bool isMeal;
  final String? mealName;
  final List<Map<String, dynamic>>? mealItems;

  DailyFoodEntry({
    required this.id,
    required this.food,
    required this.amount,
    required this.date,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    this.isMeal = false,
    this.mealName,
    this.mealItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'amount': amount,
      'date': date,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'calories': calories,
      'isMeal': isMeal,
      'mealName': mealName,
      'mealItems': mealItems,
    };
  }

  factory DailyFoodEntry.fromJson(Map<String, dynamic> json) {
    return DailyFoodEntry(
      id: json['id'],
      food: FoodItem.fromJson(json['food']),
      amount: (json['amount'] as num).toDouble(),
      date: json['date'],
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      isMeal: json['isMeal'] ?? false,
      mealName: json['mealName'],
      mealItems: json['mealItems'] != null
          ? List<Map<String, dynamic>>.from(json['mealItems'])
          : null,
    );
  }
}