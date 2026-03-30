import 'package:flutter/material.dart';
import 'models/daily_food_entry.dart';

class DaySummary {
  final String date;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;

  DaySummary({
    required this.date,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });
}

class HistoryScreen extends StatelessWidget {
  final List<DailyFoodEntry> allEntries;

  const HistoryScreen({
    super.key,
    required this.allEntries,
  });

  String dayNameFromDate(String date) {
    final parsed = DateTime.parse(date);
    const names = [
      'Ponedjeljak',
      'Utorak',
      'Srijeda',
      'Četvrtak',
      'Petak',
      'Subota',
      'Nedjelja',
    ];
    return names[parsed.weekday - 1];
  }

  List<DaySummary> buildSummaries() {
    final Map<String, List<DailyFoodEntry>> grouped = {};

    for (final entry in allEntries) {
      grouped.putIfAbsent(entry.date, () => []);
      grouped[entry.date]!.add(entry);
    }

    final summaries = grouped.entries.map((entry) {
      final date = entry.key;
      final items = entry.value;

      final protein = items.fold(0.0, (sum, e) => sum + e.protein);
      final carbs = items.fold(0.0, (sum, e) => sum + e.carbs);
      final fat = items.fold(0.0, (sum, e) => sum + e.fat);
      final calories = items.fold(0.0, (sum, e) => sum + e.calories);

      return DaySummary(
        date: date,
        protein: protein,
        carbs: carbs,
        fat: fat,
        calories: calories,
      );
    }).toList();

    summaries.sort((a, b) => b.date.compareTo(a.date));
    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    final summaries = buildSummaries();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Povijest'),
        centerTitle: true,
      ),
      body: summaries.isEmpty
          ? const Center(
        child: Text(
          'Još nema spremljene povijesti.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: summaries.length,
        itemBuilder: (context, index) {
          final day = summaries[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.calendar_month),
              ),
              title: Text('${day.date} • ${dayNameFromDate(day.date)}'),
              subtitle: Text(
                'P: ${day.protein.toStringAsFixed(1)} g | UH: ${day.carbs.toStringAsFixed(1)} g | M: ${day.fat.toStringAsFixed(1)} g | kcal: ${day.calories.toStringAsFixed(1)}',
              ),
            ),
          );
        },
      ),
    );
  }
}