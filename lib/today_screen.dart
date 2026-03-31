import 'package:flutter/material.dart';
import 'models/daily_food_entry.dart';

class TodayScreen extends StatelessWidget {
  final List<DailyFoodEntry> entries;
  final void Function(DailyFoodEntry entry) onDeleteEntry;
  final DateTime selectedDate;
  final VoidCallback onPickDate;

  const TodayScreen({
    super.key,
    required this.entries,
    required this.onDeleteEntry,
    required this.selectedDate,
    required this.onPickDate,
  });

  String _formatNum(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  void _showMealDetails(BuildContext context, DailyFoodEntry entry) {
    final items = entry.mealItems ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(entry.mealName ?? entry.food.name),
          content: SizedBox(
            width: double.maxFinite,
            child: items.isEmpty
                ? const Text('Nema stavki za prikaz.')
                : ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Količina: ${_formatNum((item['amount'] as num).toDouble())} ${item['baseUnit']}',
                    ),
                    Text(
                      'P: ${_formatNum((item['protein'] as num).toDouble())} | '
                          'UH: ${_formatNum((item['carbs'] as num).toDouble())} | '
                          'M: ${_formatNum((item['fat'] as num).toDouble())} | '
                          'kcal: ${_formatNum((item['calories'] as num).toDouble())}',
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Zatvori'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalProtein = entries.fold<double>(0, (sum, e) => sum + e.protein);
    final totalCarbs = entries.fold<double>(0, (sum, e) => sum + e.carbs);
    final totalFat = entries.fold<double>(0, (sum, e) => sum + e.fat);
    final totalCalories = entries.fold<double>(0, (sum, e) => sum + e.calories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onPickDate,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(
                      '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Proteini: ${_formatNum(totalProtein)} g'),
                    Text('UH: ${_formatNum(totalCarbs)} g'),
                    Text('Masti: ${_formatNum(totalFat)} g'),
                    Text('Kalorije: ${_formatNum(totalCalories)} kcal'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entries.isEmpty
                  ? const Center(
                child: Text(
                  'Nema unosa za odabrani datum.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          entry.isMeal ? Icons.restaurant_menu : Icons.fastfood,
                        ),
                      ),
                      title: Text(entry.isMeal
                          ? (entry.mealName ?? entry.food.name)
                          : entry.food.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'P: ${_formatNum(entry.protein)} | '
                                'UH: ${_formatNum(entry.carbs)} | '
                                'M: ${_formatNum(entry.fat)} | '
                                'kcal: ${_formatNum(entry.calories)}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.isMeal
                                ? 'Količina: ${_formatNum(entry.amount)} porcija • Dodirni za stavke obroka'
                                : 'Količina: ${_formatNum(entry.amount)} ${entry.food.baseUnit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      onTap: entry.isMeal
                          ? () => _showMealDetails(context, entry)
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDeleteEntry(entry),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}