import 'package:flutter/material.dart';
import 'models/food_category_data.dart';
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
  String selectedCategory = 'Ostalo';

  @override
  void initState() {
    super.initState();

    if (widget.existingFood != null) {
      final food = widget.existingFood!;
      nameController.text = food.name;
      proteinController.text = _formatNumber(food.protein);
      carbsController.text = _formatNumber(food.carbs);
      fatController.text = _formatNumber(food.fat);
      caloriesController.text = _formatNumber(food.calories);
      baseUnit = food.baseUnit;
      selectedCategory = food.category;
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

  String _formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  double? _parseRequiredNumber(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  void saveFood() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upiši naziv namirnice.')),
      );
      return;
    }

    final protein = _parseRequiredNumber(proteinController.text);
    final carbs = _parseRequiredNumber(carbsController.text);
    final fat = _parseRequiredNumber(fatController.text);
    final calories = _parseRequiredNumber(caloriesController.text);

    if (protein == null ||
        carbs == null ||
        fat == null ||
        calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unesi sve makronutrijente i kalorije prije spremanja.',
          ),
        ),
      );
      return;
    }

    if (protein < 0 || carbs < 0 || fat < 0 || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vrijednosti ne mogu biti negativne.'),
        ),
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
      category: selectedCategory,
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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategorija',
                border: OutlineInputBorder(),
              ),
              items: predefinedFoodCategories
                  .map(
                    (category) => DropdownMenuItem(
                  value: category.name,
                  child: Text(category.name),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Proteini',
                hintText: 'Obavezno polje',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'UH',
                hintText: 'Obavezno polje',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Masti',
                hintText: 'Obavezno polje',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Kalorije',
                hintText: 'Obavezno polje',
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
                DropdownMenuItem(value: '100ml', child: Text('100ml')),
                DropdownMenuItem(value: 'porcija', child: Text('porcija')),
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