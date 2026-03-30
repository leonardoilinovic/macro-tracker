import 'package:flutter/material.dart';
import 'models/food_item.dart';
import 'models/meal_template.dart';

class ManualMealScreen extends StatefulWidget {
  const ManualMealScreen({super.key});

  @override
  State<ManualMealScreen> createState() => _ManualMealScreenState();
}

class _ManualMealScreenState extends State<ManualMealScreen> {
  final nameController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final caloriesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    caloriesController.dispose();
    super.dispose();
  }

  String generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  void saveManualMeal() {
    final name = nameController.text.trim();
    final protein = double.tryParse(proteinController.text.trim()) ?? 0;
    final carbs = double.tryParse(carbsController.text.trim()) ?? 0;
    final fat = double.tryParse(fatController.text.trim()) ?? 0;
    final calories = double.tryParse(caloriesController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upiši naziv obroka.')),
      );
      return;
    }

    final manualFood = FoodItem(
      id: generateId(),
      name: name,
      protein: protein,
      carbs: carbs,
      fat: fat,
      calories: calories,
      baseUnit: 'porcija',
    );

    final meal = MealTemplate(
      id: generateId(),
      name: name,
      items: [
        MealTemplateItem(
          food: manualFood,
          amount: 1,
        ),
      ],
    );

    Navigator.pop(context, meal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj ručni obrok'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Naziv obroka',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Proteini za 1 porciju',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'UH za 1 porciju',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Masti za 1 porciju',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Kalorije za 1 porciju',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveManualMeal,
              child: const Text('Spremi obrok'),
            ),
          ],
        ),
      ),
    );
  }
}