import 'package:flutter/material.dart';
import 'models/meal_template.dart';

class MealsScreen extends StatefulWidget {
  final List<MealTemplate> meals;
  final void Function(MealTemplate meal, double quantity) onAddMealToToday;
  final void Function(MealTemplate meal) onDeleteMeal;
  final void Function(MealTemplate meal) onEditMeal;

  const MealsScreen({
    super.key,
    required this.meals,
    required this.onAddMealToToday,
    required this.onDeleteMeal,
    required this.onEditMeal,
  });

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MealTemplate> get filteredMeals {
    if (_searchQuery.trim().isEmpty) return widget.meals;

    final query = _searchQuery.toLowerCase().trim();
    return widget.meals.where((meal) {
      return meal.name.toLowerCase().contains(query);
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

  Future<void> _showAddMealQuantityDialog(MealTemplate meal) async {
    final quantity = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Dodaj "${meal.name}"'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(1.0),
                    child: const Text('1 porcija'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(1.5),
                    child: const Text('1.5 porcija'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(2.0),
                    child: const Text('2 porcije'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(-1.0),
                    child: const Text('Custom'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || quantity == null) return;

    double? finalQuantity = quantity;

    if (quantity == -1.0) {
      finalQuantity = await _pickCustomQuantity();
      if (!mounted || finalQuantity == null) return;
    }

    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;
    widget.onAddMealToToday(meal, finalQuantity);
  }

  Future<double?> _pickCustomQuantity() async {
    return showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _CustomQuantityDialog(),
    );
  }

  Widget _buildMealCard(MealTemplate meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAddMealQuantityDialog(meal),
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
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restaurant_menu),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => widget.onEditMeal(meal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => widget.onDeleteMeal(meal),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${meal.items.length} stavki u obroku',
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
                    _macroChip('P', _formatNum(meal.protein)),
                    _macroChip('UH', _formatNum(meal.carbs)),
                    _macroChip('M', _formatNum(meal.fat)),
                    _macroChip('kcal', _formatNum(meal.calories)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Dodirni za odabir količine',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
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
    final meals = filteredMeals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Obroci'),
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
                hintText: 'Pretraži obroke...',
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
            child: widget.meals.isEmpty
                ? const Center(
              child: Text(
                'Još nema spremljenih obroka.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : meals.isEmpty
                ? const Center(
              child: Text(
                'Nema rezultata za ovu pretragu.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return _buildMealCard(meal);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomQuantityDialog extends StatefulWidget {
  const _CustomQuantityDialog();

  @override
  State<_CustomQuantityDialog> createState() => _CustomQuantityDialogState();
}

class _CustomQuantityDialogState extends State<_CustomQuantityDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);

    if (value == null || value <= 0) {
      setState(() {
        _errorText = 'Unesi količinu veću od 0';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom količina'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Količina',
            hintText: 'npr. 2.2',
            errorText: _errorText,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}