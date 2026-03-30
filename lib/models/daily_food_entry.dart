import 'food_item.dart';

class DailyFoodEntry {
  final String id;
  final FoodItem food;
  final double amount;
  final String date; // npr. 2026-03-30

  DailyFoodEntry({
    required this.id,
    required this.food,
    required this.amount,
    required this.date,
  });

  double get protein => (food.protein * amount) / _baseAmount;
  double get carbs => (food.carbs * amount) / _baseAmount;
  double get fat => (food.fat * amount) / _baseAmount;
  double get calories => (food.calories * amount) / _baseAmount;

  double get _baseAmount {
    if (food.baseUnit == '100g') return 100;
    return 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'amount': amount,
      'date': date,
    };
  }

  factory DailyFoodEntry.fromJson(Map<String, dynamic> json) {
    return DailyFoodEntry(
      id: json['id'],
      food: FoodItem.fromJson(Map<String, dynamic>.from(json['food'])),
      amount: (json['amount'] as num).toDouble(),
      date: json['date'],
    );
  }
}