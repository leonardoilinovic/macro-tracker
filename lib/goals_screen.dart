import 'package:flutter/material.dart';
import 'models/macro_goals.dart';

class GoalsScreen extends StatefulWidget {
  final MacroGoals currentGoals;

  const GoalsScreen({
    super.key,
    required this.currentGoals,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final proteinMinController = TextEditingController();
  final proteinMaxController = TextEditingController();

  final carbsMinController = TextEditingController();
  final carbsMaxController = TextEditingController();

  final fatMinController = TextEditingController();
  final fatMaxController = TextEditingController();

  final caloriesMinController = TextEditingController();
  final caloriesMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();

    proteinMinController.text = widget.currentGoals.proteinMin.toString();
    proteinMaxController.text = widget.currentGoals.proteinMax.toString();

    carbsMinController.text = widget.currentGoals.carbsMin.toString();
    carbsMaxController.text = widget.currentGoals.carbsMax.toString();

    fatMinController.text = widget.currentGoals.fatMin.toString();
    fatMaxController.text = widget.currentGoals.fatMax.toString();

    caloriesMinController.text = widget.currentGoals.caloriesMin.toString();
    caloriesMaxController.text = widget.currentGoals.caloriesMax.toString();
  }

  @override
  void dispose() {
    proteinMinController.dispose();
    proteinMaxController.dispose();

    carbsMinController.dispose();
    carbsMaxController.dispose();

    fatMinController.dispose();
    fatMaxController.dispose();

    caloriesMinController.dispose();
    caloriesMaxController.dispose();

    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;
  }

  Widget _rangeFieldRow({
    required String title,
    required String suffix,
    required TextEditingController minController,
    required TextEditingController maxController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Min $suffix',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '–',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Max $suffix',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void saveGoals() {
    final proteinMin = _parse(proteinMinController);
    final proteinMax = _parse(proteinMaxController);

    final carbsMin = _parse(carbsMinController);
    final carbsMax = _parse(carbsMaxController);

    final fatMin = _parse(fatMinController);
    final fatMax = _parse(fatMaxController);

    final caloriesMin = _parse(caloriesMinController);
    final caloriesMax = _parse(caloriesMaxController);

    if (proteinMin > proteinMax ||
        carbsMin > carbsMax ||
        fatMin > fatMax ||
        caloriesMin > caloriesMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Min vrijednost ne može biti veća od max vrijednosti.'),
        ),
      );
      return;
    }

    final goals = MacroGoals(
      proteinMin: proteinMin,
      proteinMax: proteinMax,
      carbsMin: carbsMin,
      carbsMax: carbsMax,
      fatMin: fatMin,
      fatMax: fatMax,
      caloriesMin: caloriesMin,
      caloriesMax: caloriesMax,
    );

    Navigator.pop(context, goals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciljevi makronutrijenata'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _rangeFieldRow(
              title: 'Proteini',
              suffix: '(g)',
              minController: proteinMinController,
              maxController: proteinMaxController,
            ),
            const SizedBox(height: 16),
            _rangeFieldRow(
              title: 'UH',
              suffix: '(g)',
              minController: carbsMinController,
              maxController: carbsMaxController,
            ),
            const SizedBox(height: 16),
            _rangeFieldRow(
              title: 'Masti',
              suffix: '(g)',
              minController: fatMinController,
              maxController: fatMaxController,
            ),
            const SizedBox(height: 16),
            _rangeFieldRow(
              title: 'Kalorije',
              suffix: '(kcal)',
              minController: caloriesMinController,
              maxController: caloriesMaxController,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveGoals,
              child: const Text('Spremi ciljeve'),
            ),
          ],
        ),
      ),
    );
  }
}