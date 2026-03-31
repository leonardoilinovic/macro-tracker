import 'package:flutter/material.dart';
import 'models/food_item.dart';
import 'models/meal_template.dart';

class AddMealScreen extends StatefulWidget {
  final List<FoodItem> foods;
  final MealTemplate? existingMeal;

  const AddMealScreen({
    super.key,
    required this.foods,
    this.existingMeal,
  });

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final nameController = TextEditingController();
  final Map<String, TextEditingController> amountControllers = {};

  bool get isEditing => widget.existingMeal != null;

  @override
  void initState() {
    super.initState();

    for (final food in widget.foods) {
      amountControllers[food.id] = TextEditingController();
    }

    if (widget.existingMeal != null) {
      nameController.text = widget.existingMeal!.name;

      for (final item in widget.existingMeal!.items) {
        if (amountControllers.containsKey(item.food.id)) {
          amountControllers[item.food.id]!.text = _formatAmount(item.amount);
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    for (final controller in amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  String _formatAmount(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  void saveMeal() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upiši naziv obroka.')),
      );
      return;
    }

    final List<MealTemplateItem> items = [];

    for (final food in widget.foods) {
      final rawValue = amountControllers[food.id]!.text.trim();

      if (rawValue.isEmpty) continue;

      final amount = double.tryParse(rawValue.replaceAll(',', '.'));

      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Neispravna količina za namirnicu: ${food.name}'),
          ),
        );
        return;
      }

      if (amount > 0) {
        items.add(
          MealTemplateItem(
            food: food,
            amount: amount,
          ),
        );
      }
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upiši barem jednu količinu za obrok.')),
      );
      return;
    }

    final meal = MealTemplate(
      id: widget.existingMeal?.id ?? generateId(),
      name: name,
      items: items,
    );

    Navigator.pop(context, meal);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.foods.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Uredi obrok' : 'Dodaj obrok'),
        ),
        body: const Center(
          child: Text('Prvo dodaj barem jednu namirnicu.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Uredi obrok' : 'Dodaj obrok'),
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
            const SizedBox(height: 16),
            Text(
              isEditing
                  ? 'Promijeni količine za namirnice u obroku:'
                  : 'Unesi količine za namirnice koje želiš uključiti u obrok:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.foods.map((food) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: amountControllers[food.id],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '${food.name} (${food.baseUnit})',
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveMeal,
              child: Text(isEditing ? 'Spremi promjene' : 'Spremi obrok'),
            ),
          ],
        ),
      ),
    );
  }
}