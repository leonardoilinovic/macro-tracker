import 'package:flutter/material.dart';
import 'models/meal_template.dart';

class MealsScreen extends StatelessWidget {
  final List<MealTemplate> meals;
  final void Function(MealTemplate meal) onAddMealToToday;
  final void Function(MealTemplate meal) onDeleteMeal;

  const MealsScreen({
    super.key,
    required this.meals,
    required this.onAddMealToToday,
    required this.onDeleteMeal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obroci'),
        centerTitle: true,
      ),
      body: meals.isEmpty
          ? const Center(
        child: Text(
          'Još nema spremljenih obroka.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.restaurant_menu),
              ),
              title: Text(meal.name),
              subtitle: Text(
                'P: ${meal.protein.toStringAsFixed(1)} | UH: ${meal.carbs.toStringAsFixed(1)} | M: ${meal.fat.toStringAsFixed(1)} | kcal: ${meal.calories.toStringAsFixed(1)}',
              ),
              onTap: () => onAddMealToToday(meal),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onDeleteMeal(meal),
              ),
            ),
          );
        },
      ),
    );
  }
}