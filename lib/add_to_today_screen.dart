import 'package:flutter/material.dart';
import 'models/daily_food_entry.dart';
import 'models/food_item.dart';

class AddToTodayScreen extends StatefulWidget {
  final FoodItem food;
  final DateTime initialDate;

  const AddToTodayScreen({
    super.key,
    required this.food,
    required this.initialDate,
  });

  @override
  State<AddToTodayScreen> createState() => _AddToTodayScreenState();
}

class _AddToTodayScreenState extends State<AddToTodayScreen> {
  final amountController = TextEditingController();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  String generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  double _parseBaseUnit(String baseUnit) {
    final digits = RegExp(r'(\d+)').firstMatch(baseUnit);
    if (digits != null) {
      return double.tryParse(digits.group(1)!) ?? 100;
    }

    if (baseUnit == 'kom' || baseUnit == 'mjerica' || baseUnit == 'porcija') {
      return 1;
    }

    return 100;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void saveEntry() {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upiši ispravnu količinu.')),
      );
      return;
    }

    final base = _parseBaseUnit(widget.food.baseUnit);

    final protein = widget.food.protein * amount / base;
    final carbs = widget.food.carbs * amount / base;
    final fat = widget.food.fat * amount / base;
    final calories = widget.food.calories * amount / base;

    final entry = DailyFoodEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      food: widget.food,
      amount: amount,
      date: _formatDate(selectedDate),
      protein: protein,
      carbs: carbs,
      fat: fat,
      calories: calories,
      isMeal: false,
    );

    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final unitText = widget.food.baseUnit == '100g'
        ? 'Količina u gramima'
        : 'Količina u jedinicama';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(widget.food.name),
                subtitle: Text(
                  'P: ${widget.food.protein} | UH: ${widget.food.carbs} | M: ${widget.food.fat} | kcal: ${widget.food.calories} (${widget.food.baseUnit})',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Datum'),
              subtitle: Text(formatDate(selectedDate)),
              trailing: ElevatedButton(
                onPressed: pickDate,
                child: const Text('Promijeni'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: unitText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveEntry,
              child: const Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }
}