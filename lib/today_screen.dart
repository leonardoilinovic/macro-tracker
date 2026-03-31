import 'package:flutter/material.dart';
import 'models/daily_food_entry.dart';
import 'models/macro_goals.dart';

class TodayScreen extends StatelessWidget {
  final List<DailyFoodEntry> entries;
  final void Function(DailyFoodEntry entry) onDeleteEntry;
  final Future<void> Function(DailyFoodEntry entry, double newAmount) onEditEntry;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final MacroGoals goals;

  const TodayScreen({
    super.key,
    required this.entries,
    required this.onDeleteEntry,
    required this.onEditEntry,
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

  String _unitOnly(String baseUnit) {
    final match = RegExp(r'^\s*[\d.,]+\s*([^\d\s].*|[A-Za-zčćžšđČĆŽŠĐ]+)\s*$')
        .firstMatch(baseUnit);

    if (match != null) {
      return match.group(1)!.trim();
    }

    return baseUnit.trim();
  }

  String _formatAmountWithBaseUnit(double amount, String baseUnit) {
    final match = RegExp(r'^\s*[\d.,]+\s*([^\d\s].*|[A-Za-zčćžšđČĆŽŠĐ]+)\s*$')
        .firstMatch(baseUnit);

    if (match != null) {
      final unit = match.group(1)!.trim();
      return '${_formatNum(amount)} $unit';
    }

    return '${_formatNum(amount)} $baseUnit';
  }

  Future<void> _showEditAmountDialog(
      BuildContext context,
      DailyFoodEntry entry,
      ) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _EditAmountDialog(
        initialValue: entry.amount,
        isMeal: entry.isMeal,
        unitLabel: entry.isMeal ? 'porcija' : _unitOnly(entry.food.baseUnit),
      ),
    );

    if (result == null) return;
    await onEditEntry(entry, result);
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

  _RangeStatus _buildRangeStatus({
    required double actual,
    required double min,
    required double max,
    required String unit,
  }) {
    final hasGoal = min > 0 || max > 0;

    if (!hasGoal) {
      return _RangeStatus(
        color: Colors.grey,
        progress: 0,
        helperText: 'Cilj nije postavljen',
        rangeText: '—',
      );
    }

    final safeMax = max <= 0 ? min : max;
    final progress = safeMax > 0 ? (actual / safeMax).clamp(0.0, 1.0) : 0.0;
    final rangeText = '${_formatNum(min)}–${_formatNum(max)} $unit';

    if (actual < min) {
      return _RangeStatus(
        color: Colors.orange,
        progress: progress,
        helperText: 'Preostalo do cilja: ${_formatNum(min - actual)} $unit',
        rangeText: rangeText,
      );
    }

    if (actual <= max) {
      return _RangeStatus(
        color: Colors.green,
        progress: progress,
        helperText: 'U ciljanom rasponu si',
        rangeText: rangeText,
      );
    }

    return _RangeStatus(
      color: Colors.red,
      progress: progress,
      helperText: 'Prešao si za ${_formatNum(actual - max)} $unit',
      rangeText: rangeText,
    );
  }

  Widget _buildMacroCard({
    required String title,
    required double actual,
    required double min,
    required double max,
    required String unit,
    required IconData icon,
  }) {
    final status = _buildRangeStatus(
      actual: actual,
      min: min,
      max: max,
      unit: unit,
    );

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatNum(actual)} $unit',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      status.rangeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: status.progress,
                color: status.color,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status.helperText,
              style: TextStyle(
                color: status.color,
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
                  ? 'Količina: ${_formatNum(entry.amount)} porcija'
                  : 'Količina: ${_formatAmountWithBaseUnit(entry.amount, entry.food.baseUnit)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        onTap: entry.isMeal ? () => _showMealDetails(context, entry) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditAmountDialog(context, entry),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onDeleteEntry(entry),
            ),
          ],
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
            min: goals.proteinMin,
            max: goals.proteinMax,
            unit: 'g',
            icon: Icons.fitness_center,
          ),
          _buildMacroCard(
            title: 'UH',
            actual: totalCarbs,
            min: goals.carbsMin,
            max: goals.carbsMax,
            unit: 'g',
            icon: Icons.rice_bowl,
          ),
          _buildMacroCard(
            title: 'Masti',
            actual: totalFat,
            min: goals.fatMin,
            max: goals.fatMax,
            unit: 'g',
            icon: Icons.opacity,
          ),
          _buildMacroCard(
            title: 'Kalorije',
            actual: totalCalories,
            min: goals.caloriesMin,
            max: goals.caloriesMax,
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

class _EditAmountDialog extends StatefulWidget {
  final double initialValue;
  final bool isMeal;
  final String unitLabel;

  const _EditAmountDialog({
    required this.initialValue,
    required this.isMeal,
    required this.unitLabel,
  });

  @override
  State<_EditAmountDialog> createState() => _EditAmountDialogState();
}

class _EditAmountDialogState extends State<_EditAmountDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  String _initialText(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _initialText(widget.initialValue),
    );
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

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isMeal
            ? 'Uredi količinu obroka'
            : 'Uredi količinu namirnice',
      ),
      content: TextField(
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
          labelText: 'Količina (${widget.unitLabel})',
          hintText: 'npr. 150',
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Spremi'),
        ),
      ],
    );
  }
}

class _RangeStatus {
  final Color color;
  final double progress;
  final String helperText;
  final String rangeText;

  const _RangeStatus({
    required this.color,
    required this.progress,
    required this.helperText,
    required this.rangeText,
  });
}