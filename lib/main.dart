import 'package:flutter/material.dart';
import 'add_food_screen.dart';
import 'add_meal_screen.dart';
import 'add_to_today_screen.dart';
import 'foods_screen.dart';
import 'meals_screen.dart';
import 'today_screen.dart';
import 'models/daily_food_entry.dart';
import 'models/food_item.dart';
import 'models/meal_template.dart';
import 'services/storage_service.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'models/macro_goals.dart';
import 'manual_meal_screen.dart';


void main() {
  runApp(const MacroTrackerApp());
}

class MacroTrackerApp extends StatelessWidget {
  const MacroTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Macro Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<FoodItem> foods = [];
  final List<DailyFoodEntry> todayEntries = [];
  final List<MealTemplate> meals = [];

  int selectedIndex = 0;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  MacroGoals goals = MacroGoals.empty();

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final loadedFoods = await StorageService.loadFoods();
    final loadedEntries = await StorageService.loadTodayEntries();
    final loadedMeals = await StorageService.loadMeals();
    final loadedGoals = await StorageService.loadGoals();

    setState(() {
      foods.clear();
      foods.addAll(loadedFoods);

      todayEntries.clear();
      todayEntries.addAll(loadedEntries);

      meals.clear();
      meals.addAll(loadedMeals);

      goals = loadedGoals;
      isLoading = false;
    });
  }

  Future<void> persistAll() async {
    await StorageService.saveFoods(foods);
    await StorageService.saveTodayEntries(todayEntries);
    await StorageService.saveMeals(meals);
  }

  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> pickSelectedDate() async {
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

  Future<bool> showDeleteConfirmation(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> openGoalsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalsScreen(currentGoals: goals),
      ),
    );

    if (result != null && result is MacroGoals) {
      setState(() {
        goals = result;
      });
      await StorageService.saveGoals(goals);
    }
  }


  Future<void> openAddFoodScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFoodScreen(),
      ),
    );

    if (result != null && result is FoodItem) {
      setState(() {
        foods.add(result);
        selectedIndex = 1;
      });
      await StorageService.saveFoods(foods);
    }
  }

  Future<void> openManualMealScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualMealScreen(),
      ),
    );

    if (result != null && result is MealTemplate) {
      setState(() {
        meals.add(result);
        selectedIndex = 2;
      });
      await StorageService.saveMeals(meals);
    }
  }

  Future<void> openAddMealScreen() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Obrok iz postojećih namirnica'),
                onTap: () => Navigator.pop(context, 'template'),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Ručni obrok (npr. menza)'),
                onTap: () => Navigator.pop(context, 'manual'),
              ),
            ],
          ),
        );
      },
    );

    if (choice == 'template') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMealScreen(foods: foods),
        ),
      );

      if (result != null && result is MealTemplate) {
        setState(() {
          meals.add(result);
          selectedIndex = 2;
        });
        await StorageService.saveMeals(meals);
      }
    }

    if (choice == 'manual') {
      await openManualMealScreen();
    }
  }

  Future<void> openAddToTodayScreen(FoodItem food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddToTodayScreen(
          food: food,
          initialDate: selectedDate,
        ),
      ),
    );

    if (result != null && result is DailyFoodEntry) {
      setState(() {
        todayEntries.add(result);
        selectedIndex = 0;
      });
      await StorageService.saveTodayEntries(todayEntries);
    }
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

  void addMealToToday(MealTemplate meal, double quantity) async {
    final selectedDateString = formatDate(selectedDate);

    final scaledProtein = meal.protein * quantity;
    final scaledCarbs = meal.carbs * quantity;
    final scaledFat = meal.fat * quantity;
    final scaledCalories = meal.calories * quantity;

    final mealFood = FoodItem(
      id: 'meal_${meal.id}',
      name: meal.name,
      protein: scaledProtein,
      carbs: scaledCarbs,
      fat: scaledFat,
      calories: scaledCalories,
      baseUnit: 'porcija',
      category: 'Ostalo',
    );

    final mealItems = meal.items.map((item) {
      final base = _parseBaseUnit(item.food.baseUnit);
      final scaledAmount = item.amount * quantity;

      final itemProtein = item.food.protein * scaledAmount / base;
      final itemCarbs = item.food.carbs * scaledAmount / base;
      final itemFat = item.food.fat * scaledAmount / base;
      final itemCalories = item.food.calories * scaledAmount / base;

      return {
        'name': item.food.name,
        'amount': scaledAmount,
        'baseUnit': item.food.baseUnit,
        'protein': itemProtein,
        'carbs': itemCarbs,
        'fat': itemFat,
        'calories': itemCalories,
      };
    }).toList();

    final entry = DailyFoodEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      food: mealFood,
      amount: quantity,
      date: selectedDateString,
      protein: scaledProtein,
      carbs: scaledCarbs,
      fat: scaledFat,
      calories: scaledCalories,
      isMeal: true,
      mealName: meal.name,
      mealItems: mealItems,
    );

    setState(() {
      todayEntries.add(entry);
      selectedIndex = 0;
    });

    await StorageService.saveTodayEntries(todayEntries);

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${meal.name} dodan (${quantity.toString().replaceAll('.0', '')} porcija)',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }


  Future<void> openEditMealScreen(MealTemplate meal) async {
    final canEditWithCurrentScreen = meal.items.every(
          (item) => foods.any((food) => food.id == item.food.id),
    );

    if (!canEditWithCurrentScreen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ovaj obrok je ručno unesen. Uređivanje ručnih obroka dodat ćemo zasebno.',
          ),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          foods: foods,
          existingMeal: meal,
        ),
      ),
    );

    if (result != null && result is MealTemplate) {
      final index = meals.indexWhere((item) => item.id == meal.id);

      if (index != -1) {
        setState(() {
          meals[index] = result;
          selectedIndex = 2;
        });

        await StorageService.saveMeals(meals);
      }
    }
  }

  Future<void> openEditFoodScreen(FoodItem food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(existingFood: food),
      ),
    );

    if (result != null && result is FoodItem) {
      final index = foods.indexWhere((item) => item.id == food.id);

      if (index != -1) {
        setState(() {
          foods[index] = result;
        });
        await StorageService.saveFoods(foods);
      }
    }
  }

  Future<void> deleteFood(FoodItem food) async {
    final confirmed = await showDeleteConfirmation(
      'Obriši namirnicu',
      'Jesi li siguran da želiš obrisati "${food.name}"?',
    );

    if (!confirmed) return;

    setState(() {
      foods.removeWhere((item) => item.id == food.id);
    });
    await StorageService.saveFoods(foods);
  }

  Future<void> deleteMeal(MealTemplate meal) async {
    final confirmed = await showDeleteConfirmation(
      'Obriši obrok',
      'Jesi li siguran da želiš obrisati obrok "${meal.name}"?',
    );

    if (!confirmed) return;

    setState(() {
      meals.removeWhere((item) => item.id == meal.id);
    });
    await StorageService.saveMeals(meals);
  }

  Future<void> deleteTodayEntry(DailyFoodEntry entry) async {
    final confirmed = await showDeleteConfirmation(
      'Obriši unos',
      'Jesi li siguran da želiš obrisati unos "${entry.food.name}"?',
    );

    if (!confirmed) return;

    setState(() {
      todayEntries.removeWhere((item) => item.id == entry.id);
    });
    await StorageService.saveTodayEntries(todayEntries);
  }

  String todayDateString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  List<DailyFoodEntry> get todaysEntries {
    final selectedDateString = formatDate(selectedDate);
    return todayEntries.where((entry) => entry.date == selectedDateString).toList();
  }

  double get totalProtein =>
      todaysEntries.fold(0, (sum, entry) => sum + entry.protein);

  double get totalCarbs =>
      todaysEntries.fold(0, (sum, entry) => sum + entry.carbs);

  double get totalFat =>
      todaysEntries.fold(0, (sum, entry) => sum + entry.fat);

  double get totalCalories =>
      todaysEntries.fold(0, (sum, entry) => sum + entry.calories);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      HomeTab(
        onAddFood: openAddFoodScreen,
        onAddMeal: openAddMealScreen,
        onOpenGoals: openGoalsScreen,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        calories: totalCalories,
        goals: goals,
      ),
      FoodsScreen(
        foods: foods,
        onFoodTap: openAddToTodayScreen,
        onDeleteFood: deleteFood,
        onEditFood: openEditFoodScreen,
        onAddFood: openAddFoodScreen,
      ),
      MealsScreen(
        meals: meals,
        onAddMealToToday: addMealToToday,
        onDeleteMeal: deleteMeal,
        onEditMeal: openEditMealScreen,
      ),
      TodayScreen(
        entries: todaysEntries,
        onDeleteEntry: deleteTodayEntry,
        selectedDate: selectedDate,
        onPickDate: pickSelectedDate,
      ),
      HistoryScreen(
        allEntries: todayEntries,
      ),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Početna',
          ),
          NavigationDestination(
            icon: Icon(Icons.fastfood_outlined),
            selectedIcon: Icon(Icons.fastfood),
            label: 'Namirnice',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Obroci',
          ),
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Danas',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Povijest',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final VoidCallback onAddFood;
  final VoidCallback onAddMeal;
  final VoidCallback onOpenGoals;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;
  final MacroGoals goals;

  const HomeTab({
    super.key,
    required this.onAddFood,
    required this.onAddMeal,
    required this.onOpenGoals,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro Tracker'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            DailySummaryCard(
              protein: protein,
              carbs: carbs,
              fat: fat,
              calories: calories,
            ),
            const SizedBox(height: 16),
            GoalsOverviewCard(
              goals: goals,
              protein: protein,
              carbs: carbs,
              fat: fat,
              calories: calories,
              onEditGoals: onOpenGoals,
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                ActionCard(
                  title: 'Dodaj namirnicu',
                  icon: Icons.fastfood,
                  onTap: onAddFood,
                ),
                ActionCard(
                  title: 'Dodaj obrok',
                  icon: Icons.restaurant_menu,
                  onTap: onAddMeal,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class DailySummaryCard extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double calories;

  const DailySummaryCard({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Današnji sažetak',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MacroBox(
                    label: 'Proteini',
                    value: '${protein.toStringAsFixed(1)} g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MacroBox(
                    label: 'UH',
                    value: '${carbs.toStringAsFixed(1)} g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MacroBox(
                    label: 'Masti',
                    value: '${fat.toStringAsFixed(1)} g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MacroBox(
                    label: 'Kalorije',
                    value: '${calories.toStringAsFixed(1)} kcal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GoalsOverviewCard extends StatelessWidget {
  final MacroGoals goals;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;
  final VoidCallback onEditGoals;

  const GoalsOverviewCard({
    super.key,
    required this.goals,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.onEditGoals,
  });

  String remainingText(double current, double goal, String unit) {
    if (goal <= 0) return 'Cilj nije postavljen';
    final diff = goal - current;
    if (diff > 0) {
      return 'Preostalo: ${diff.toStringAsFixed(1)} $unit';
    }
    return 'Prešao si za: ${(-diff).toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ciljevi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onEditGoals,
                  child: const Text('Uredi'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GoalRow(
              title: 'Proteini',
              current: protein,
              goal: goals.proteinGoal,
              unit: 'g',
              helperText: remainingText(protein, goals.proteinGoal, 'g'),
            ),
            const SizedBox(height: 10),
            GoalRow(
              title: 'UH',
              current: carbs,
              goal: goals.carbsGoal,
              unit: 'g',
              helperText: remainingText(carbs, goals.carbsGoal, 'g'),
            ),
            const SizedBox(height: 10),
            GoalRow(
              title: 'Masti',
              current: fat,
              goal: goals.fatGoal,
              unit: 'g',
              helperText: remainingText(fat, goals.fatGoal, 'g'),
            ),
            const SizedBox(height: 10),
            GoalRow(
              title: 'Kalorije',
              current: calories,
              goal: goals.caloriesGoal,
              unit: 'kcal',
              helperText: remainingText(calories, goals.caloriesGoal, 'kcal'),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalRow extends StatelessWidget {
  final String title;
  final double current;
  final double goal;
  final String unit;
  final String helperText;

  const GoalRow({
    super.key,
    required this.title,
    required this.current,
    required this.goal,
    required this.unit,
    required this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0, 1).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} $unit',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class MacroBox extends StatelessWidget {
  final String label;
  final String value;

  const MacroBox({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}