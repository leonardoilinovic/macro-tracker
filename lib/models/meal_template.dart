import 'food_item.dart';

class MealTemplateItem {
  final FoodItem food;
  final double amount;

  MealTemplateItem({
    required this.food,
    required this.amount,
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
      'food': food.toJson(),
      'amount': amount,
    };
  }

  factory MealTemplateItem.fromJson(Map<String, dynamic> json) {
    return MealTemplateItem(
      food: FoodItem.fromJson(Map<String, dynamic>.from(json['food'])),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class MealTemplate {
  final String id;
  final String name;
  final List<MealTemplateItem> items;

  MealTemplate({
    required this.id,
    required this.name,
    required this.items,
  });

  double get protein => items.fold(0, (sum, item) => sum + item.protein);
  double get carbs => items.fold(0, (sum, item) => sum + item.carbs);
  double get fat => items.fold(0, (sum, item) => sum + item.fat);
  double get calories => items.fold(0, (sum, item) => sum + item.calories);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory MealTemplate.fromJson(Map<String, dynamic> json) {
    return MealTemplate(
      id: json['id'],
      name: json['name'],
      items: (json['items'] as List)
          .map((e) => MealTemplateItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}