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

  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregled po datumu'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: ListTile(
                title: const Text('Odabrani datum'),
                subtitle: Text(formatDate(selectedDate)),
                trailing: ElevatedButton(
                  onPressed: onPickDate,
                  child: const Text('Promijeni'),
                ),
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(
              child: Text(
                'Nema unosa za odabrani datum.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.restaurant),
                    ),
                    title: Text(entry.food.name),
                    subtitle: Text(
                      'Količina: ${entry.amount} | P: ${entry.protein.toStringAsFixed(1)} | UH: ${entry.carbs.toStringAsFixed(1)} | M: ${entry.fat.toStringAsFixed(1)} | kcal: ${entry.calories.toStringAsFixed(1)}',
                    ),
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
    );
  }
}