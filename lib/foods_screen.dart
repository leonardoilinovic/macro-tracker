import 'package:flutter/material.dart';
import 'models/food_item.dart';

class FoodsScreen extends StatelessWidget {
  final List<FoodItem> foods;
  final void Function(FoodItem food) onFoodTap;
  final void Function(FoodItem food) onDeleteFood;
  final void Function(FoodItem food) onEditFood;
  final VoidCallback onAddFood;

  const FoodsScreen({
    super.key,
    required this.foods,
    required this.onFoodTap,
    required this.onDeleteFood,
    required this.onEditFood,
    required this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namirnice'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddFood,
        child: const Icon(Icons.add),
      ),
      body: foods.isEmpty
          ? const Center(
        child: Text(
          'Još nema spremljenih namirnica.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.fastfood),
              ),
              title: Text(food.name),
              subtitle: Text(
                'P: ${food.protein} | UH: ${food.carbs} | M: ${food.fat} | kcal: ${food.calories} (${food.baseUnit})',
              ),
              onTap: () => onFoodTap(food),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => onEditFood(food),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onDeleteFood(food),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}