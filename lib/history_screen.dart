import 'package:flutter/material.dart';
import 'models/daily_food_entry.dart';
import 'models/macro_goals.dart';

class HistoryScreen extends StatefulWidget {
  final List<DailyFoodEntry> allEntries;
  final MacroGoals goals;

  const HistoryScreen({
    super.key,
    required this.allEntries,
    required this.goals,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedRange = 7;

  String _formatNum(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  DateTime _parseDate(String date) => DateTime.parse(date);

  String _shortDate(String date) {
    final parsed = _parseDate(date);
    return '${parsed.day}.${parsed.month}.';
  }

  Map<String, List<DailyFoodEntry>> _groupByDate() {
    final map = <String, List<DailyFoodEntry>>{};
    for (final entry in widget.allEntries) {
      map.putIfAbsent(entry.date, () => []).add(entry);
    }
    return map;
  }

  List<_DayStats> _buildStats() {
    final grouped = _groupByDate();

    final stats = grouped.entries.map((entry) {
      final protein = entry.value.fold<double>(0, (sum, e) => sum + e.protein);
      final carbs = entry.value.fold<double>(0, (sum, e) => sum + e.carbs);
      final fat = entry.value.fold<double>(0, (sum, e) => sum + e.fat);
      final calories =
      entry.value.fold<double>(0, (sum, e) => sum + e.calories);

      return _DayStats(
        date: entry.key,
        protein: protein,
        carbs: carbs,
        fat: fat,
        calories: calories,
      );
    }).toList();

    stats.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
    return stats;
  }

  int _hitGoalDays(List<_DayStats> stats) {
    bool inRange(double value, double min, double max) {
      final hasGoal = min > 0 || max > 0;
      if (!hasGoal) return true;
      return value >= min && value <= max;
    }

    return stats.where((day) {
      final proteinOk =
      inRange(day.protein, widget.goals.proteinMin, widget.goals.proteinMax);
      final carbsOk =
      inRange(day.carbs, widget.goals.carbsMin, widget.goals.carbsMax);
      final fatOk = inRange(day.fat, widget.goals.fatMin, widget.goals.fatMax);
      final caloriesOk = inRange(
        day.calories,
        widget.goals.caloriesMin,
        widget.goals.caloriesMax,
      );

      return proteinOk && carbsOk && fatOk && caloriesOk;
    }).length;
  }

  Widget _rangeChip(int days) {
    final isSelected = selectedRange == days;

    return ChoiceChip(
      label: Text('$days dana'),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedRange = days;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _buildStats();
    final visibleDays = stats.take(selectedRange).toList();

    final averageCalories = visibleDays.isEmpty
        ? 0.0
        : visibleDays.fold<double>(0, (sum, d) => sum + d.calories) /
        visibleDays.length;

    final averageProtein = visibleDays.isEmpty
        ? 0.0
        : visibleDays.fold<double>(0, (sum, d) => sum + d.protein) /
        visibleDays.length;

    final maxCalories = visibleDays.isEmpty
        ? 1.0
        : visibleDays
        .map((d) => d.calories)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);

    final hitDays = _hitGoalDays(visibleDays);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trendovi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _rangeChip(7),
              _rangeChip(14),
              _rangeChip(30),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sažetak za zadnjih $selectedRange dana',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          title: 'Prosjek kcal',
                          value: _formatNum(averageCalories),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          title: 'Prosjek proteina',
                          value: '${_formatNum(averageProtein)} g',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MiniStatCard(
                    title: 'Dani pogođenog cilja',
                    value: '$hitDays / ${visibleDays.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kalorije po danima',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (visibleDays.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Nema dovoljno podataka za graf.'),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: visibleDays.reversed.map((day) {
                          final ratio =
                          (day.calories / maxCalories).clamp(0.0, 1.0);

                          return Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatNum(day.calories),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: 24,
                                        height: 160 * ratio,
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _shortDate(day.date),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Pregled za zadnjih $selectedRange dana',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (visibleDays.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('Još nema spremljenih dana za prikaz.'),
                ),
              ),
            )
          else
            ...visibleDays.map((day) {
              final overCalories = widget.goals.caloriesMax > 0 &&
                  day.calories > widget.goals.caloriesMax;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.date,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Proteini: ${_formatNum(day.protein)} g'),
                      Text('UH: ${_formatNum(day.carbs)} g'),
                      Text('Masti: ${_formatNum(day.fat)} g'),
                      Text(
                        'Kalorije: ${_formatNum(day.calories)} kcal',
                        style: TextStyle(
                          color: overCalories ? Colors.red : null,
                          fontWeight:
                          overCalories ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                      if (widget.goals.caloriesMin > 0 || widget.goals.caloriesMax > 0)
                        Text(
                          'Cilj: ${_formatNum(widget.goals.caloriesMin)}–${_formatNum(widget.goals.caloriesMax)} kcal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          if (stats.length > selectedRange) ...[
            const SizedBox(height: 8),
            Text(
              'Prikazujemo samo zadnjih $selectedRange dana radi preglednosti.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayStats {
  final String date;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;

  const _DayStats({
    required this.date,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });
}