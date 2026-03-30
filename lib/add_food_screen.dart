import 'package:flutter/material.dart';
import 'models/food_item.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodItem? existingFood;

  const AddFoodScreen({super.key, this.existingFood});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final nameController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final caloriesController = TextEditingController();

  String baseUnit = '100g';

  @override
  void initState() {
    super.initState();

    if (widget.existingFood != null) {
      final food = widget.existingFood!;
      nameController.text = food.name;
      proteinController.text = food.protein.toString();
      carbsController.text = food.carbs.toString();
      fatController.text = food.fat.toString();
      caloriesController.text = food.calories.toString();
      baseUnit = food.baseUnit;
    }
  }

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

  void saveFood() {
    final name = nameController.text.trim();
    final protein = double.tryParse(proteinController.text.trim()) ?? 0;
    final carbs = double.tryParse(carbsController.text.trim()) ?? 0;
    final fat = double.tryParse(fatController.text.trim()) ?? 0;
    final calories = double.tryParse(caloriesController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upiši naziv namirnice.')),
      );
      return;
    }

    final newFood = FoodItem(
      id: widget.existingFood?.id ?? generateId(),
      name: name,
      protein: protein,
      carbs: carbs,
      fat: fat,
      calories: calories,
      baseUnit: baseUnit,
    );

    Navigator.pop(context, newFood);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingFood != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Uredi namirnicu' : 'Dodaj namirnicu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Naziv',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Proteini',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'UH',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Masti',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Kalorije',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: baseUnit,
              decoration: const InputDecoration(
                labelText: 'Baza',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '100g', child: Text('100g')),
                DropdownMenuItem(value: 'kom', child: Text('kom')),
                DropdownMenuItem(value: 'mjerica', child: Text('mjerica')),
              ],
              onChanged: (value) {
                setState(() {
                  baseUnit = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveFood,
              child: Text(isEditing ? 'Spremi promjene' : 'Spremi'),
            ),
          ],
        ),
      ),
    );
  }
}