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
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    proteinController.text = widget.currentGoals.proteinGoal.toString();
    carbsController.text = widget.currentGoals.carbsGoal.toString();
    fatController.text = widget.currentGoals.fatGoal.toString();
    caloriesController.text = widget.currentGoals.caloriesGoal.toString();
  }

  @override
  void dispose() {
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    caloriesController.dispose();
    super.dispose();
  }

  void saveGoals() {
    final goals = MacroGoals(
      proteinGoal: double.tryParse(proteinController.text.trim()) ?? 0,
      carbsGoal: double.tryParse(carbsController.text.trim()) ?? 0,
      fatGoal: double.tryParse(fatController.text.trim()) ?? 0,
      caloriesGoal: double.tryParse(caloriesController.text.trim()) ?? 0,
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
            TextField(
              controller: proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cilj proteina (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cilj UH (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cilj masti (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cilj kalorija',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
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