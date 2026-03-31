import 'package:flutter/material.dart';
import 'models/daily_food_entry.dart';
import 'models/macro_goals.dart';

class TodayScreen extends StatelessWidget {
  final List<DailyFoodEntry> entries;
  final void Function(DailyFoodEntry entry) onDeleteEntry;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final MacroGoals goals;

  const TodayScreen({
    super.key,
    required this.entries,
    required this.onDeleteEntry,
    required this.selectedDate,
    required this.onPickDate,
    required this.goals,
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

  double _totalProtein() => entries.fold(0, (sum, e) => sum + e.protein);
  double _totalCarbs() => entries.fold(0, (sum, e) => sum + e.carbs);
  double _totalFat() => entries.fold(0, (sum, e) => sum + e.fat);
  double _totalCalories() => entries.fold(0, (sum, e) => sum + e.calories);

  Widget _buildMacroCard({
    required String title,
    required double actual,
    required double target,
    required String unit,
    required IconData icon,
  }) {
    final difference = target - actual;
    final isOver = actual > target;
    final hasGoal = target > 0;

    final color = !hasGoal
        ? Colors.grey
        : isOver
        ? Colors.red
        : Colors.green;

    final progress = hasGoal ? (actual / target).clamp(0.0, 1.0) : 0.0;

    String helperText;
    if (!hasGoal) {
      helperText = 'Cilj nije postavljen';
    } else if (difference > 0) {
      helperText = 'Preostalo: ${_formatNum(difference)} $unit';
    } else if (difference < 0) {
      helperText = 'Prešao si za ${_formatNum(difference.abs())} $unit';
    } else {
      helperText = 'Točno pogođen cilj';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${_formatNum(actual)} / ${_formatNum(target)} $unit',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                color: color,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              helperText,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, DailyFoodEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            entry.isMeal ? Icons.restaurant_menu : Icons.fastfood,
          ),
        ),
        title: Text(
          entry.isMeal ? (entry.mealName ?? entry.food.name) : entry.food.name,
        ),
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
                  ? 'Količina: ${_formatNum(entry.amount)} porcija • Dodirni za detalje'
                  : 'Količina: ${_formatNum(entry.amount)} ${entry.food.baseUnit}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        onTap: entry.isMeal ? () => _showMealDetails(context, entry) : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => onDeleteEntry(entry),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalProtein = _totalProtein();
    final totalCarbs = _totalCarbs();
    final totalFat = _totalFat();
    final totalCalories = _totalCalories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dnevnik'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onPickDate,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onPickDate,
                    child: const Text('Promijeni'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildMacroCard(
            title: 'Proteini',
            actual: totalProtein,
            target: goals.proteinGoal,
            unit: 'g',
            icon: Icons.fitness_center,
          ),
          _buildMacroCard(
            title: 'UH',
            actual: totalCarbs,
            target: goals.carbsGoal,
            unit: 'g',
            icon: Icons.rice_bowl,
          ),
          _buildMacroCard(
            title: 'Masti',
            actual: totalFat,
            target: goals.fatGoal,
            unit: 'g',
            icon: Icons.opacity,
          ),
          _buildMacroCard(
            title: 'Kalorije',
            actual: totalCalories,
            target: goals.caloriesGoal,
            unit: 'kcal',
            icon: Icons.local_fire_department,
          ),
          const SizedBox(height: 8),
          Text(
            'Unosi za odabrani datum',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('Nema unosa za odabrani datum.'),
                ),
              ),
            )
          else
            ...entries.map((entry) => _buildEntryCard(context, entry)),
        ],
      ),
    );
  }
}