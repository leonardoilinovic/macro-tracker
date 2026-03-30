import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_food_entry.dart';
import '../models/food_item.dart';
import '../models/meal_template.dart';
import '../models/macro_goals.dart';

class StorageService {
  static const String foodsKey = 'foods';
  static const String todayEntriesKey = 'today_entries';
  static const String mealsKey = 'meals';
  static const String goalsKey = 'macro_goals';

  static Future<void> saveFoods(List<FoodItem> foods) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = foods.map((food) => jsonEncode(food.toJson())).toList();
    await prefs.setStringList(foodsKey, jsonList);
  }

  static Future<List<FoodItem>> loadFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(foodsKey) ?? [];
    return jsonList
        .map((item) => FoodItem.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> saveTodayEntries(List<DailyFoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(todayEntriesKey, jsonList);
  }

  static Future<List<DailyFoodEntry>> loadTodayEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(todayEntriesKey) ?? [];
    return jsonList
        .map((item) => DailyFoodEntry.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> saveMeals(List<MealTemplate> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = meals.map((meal) => jsonEncode(meal.toJson())).toList();
    await prefs.setStringList(mealsKey, jsonList);
  }

  static Future<List<MealTemplate>> loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(mealsKey) ?? [];
    return jsonList
        .map((item) => MealTemplate.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> saveGoals(MacroGoals goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(goalsKey, jsonEncode(goals.toJson()));
  }

  static Future<MacroGoals> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(goalsKey);

    if (raw == null) {
      return MacroGoals.empty();
    }

    return MacroGoals.fromJson(jsonDecode(raw));
  }
}