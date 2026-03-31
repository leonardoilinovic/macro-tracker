import 'package:flutter/material.dart';
import 'models/food_item.dart';

class FoodCategoryScreen extends StatefulWidget {
  final String categoryName;
  final List<FoodItem> foods;
  final void Function(FoodItem food) onFoodTap;
  final void Function(FoodItem food) onDeleteFood;
  final void Function(FoodItem food) onEditFood;

  const FoodCategoryScreen({
    super.key,
    required this.categoryName,
    required this.foods,
    required this.onFoodTap,
    required this.onDeleteFood,
    required this.onEditFood,
  });

  @override
  State<FoodCategoryScreen> createState() => _FoodCategoryScreenState();
}

class _FoodCategoryScreenState extends State<FoodCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> get filteredFoods {
    final categoryFoods = widget.foods
        .where((food) => food.category == widget.categoryName)
        .toList();

    if (_searchQuery.trim().isEmpty) return categoryFoods;

    final query = _searchQuery.toLowerCase().trim();

    return categoryFoods.where((food) {
      return food.name.toLowerCase().contains(query);
    }).toList();
  }

  String _formatNum(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Widget _macroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context, food);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fastfood),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => widget.onEditFood(food),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => widget.onDeleteFood(food),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Vrijednosti po ${food.baseUnit}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _macroChip('P', _formatNum(food.protein)),
                    _macroChip('UH', _formatNum(food.carbs)),
                    _macroChip('M', _formatNum(food.fat)),
                    _macroChip('kcal', _formatNum(food.calories)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foods = filteredFoods;
    final totalInCategory = widget.foods
        .where((food) => food.category == widget.categoryName)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pretraži unutar kategorije...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: totalInCategory == 0
                ? const Center(
              child: Text(
                'Još nema namirnica u ovoj kategoriji.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : foods.isEmpty
                ? const Center(
              child: Text(
                'Nema rezultata za ovu pretragu.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return _buildFoodCard(food);
              },
            ),
          ),
        ],
      ),
    );
  }
}