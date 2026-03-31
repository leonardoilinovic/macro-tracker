import 'package:flutter/material.dart';
import 'food_category_screen.dart';
import 'models/food_category_data.dart';
import 'models/food_item.dart';

class FoodsScreen extends StatefulWidget {
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
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> get searchedFoods {
    if (_searchQuery.trim().isEmpty) return [];

    final query = _searchQuery.toLowerCase().trim();

    return widget.foods.where((food) {
      return food.name.toLowerCase().contains(query);
    }).toList();
  }

  int _countFoodsInCategory(String categoryName) {
    return widget.foods.where((food) => food.category == categoryName).length;
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
          onTap: () => widget.onFoodTap(food),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: predefinedFoodCategories.length,
      itemBuilder: (context, index) {
        final category = predefinedFoodCategories[index];
        final count = _countFoodsInCategory(category.name);

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final selectedFood = await Navigator.push<FoodItem>(
              context,
              MaterialPageRoute(
                builder: (context) => FoodCategoryScreen(
                  categoryName: category.name,
                  foods: widget.foods,
                  onFoodTap: widget.onFoodTap,
                  onDeleteFood: widget.onDeleteFood,
                  onEditFood: widget.onEditFood,
                ),
              ),
            );

            if (!mounted) return;

            if (selectedFood != null) {
              widget.onFoodTap(selectedFood);
            }
          },
          child: Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category.icon,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$count namirnica',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final foods = searchedFoods;

    if (widget.foods.isEmpty) {
      return const Center(
        child: Text(
          'Još nema spremljenih namirnica.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    if (foods.isEmpty) {
      return const Center(
        child: Text(
          'Nema rezultata za ovu pretragu.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return _buildFoodCard(food);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Namirnice'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddFood,
        child: const Icon(Icons.add),
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
                hintText: 'Pretraži sve namirnice...',
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
            child: isSearching ? _buildSearchResults() : _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }
}