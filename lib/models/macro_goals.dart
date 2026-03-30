class MacroGoals {
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double caloriesGoal;

  MacroGoals({
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.caloriesGoal,
  });

  Map<String, dynamic> toJson() {
    return {
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'caloriesGoal': caloriesGoal,
    };
  }

  factory MacroGoals.fromJson(Map<String, dynamic> json) {
    return MacroGoals(
      proteinGoal: (json['proteinGoal'] as num).toDouble(),
      carbsGoal: (json['carbsGoal'] as num).toDouble(),
      fatGoal: (json['fatGoal'] as num).toDouble(),
      caloriesGoal: (json['caloriesGoal'] as num).toDouble(),
    );
  }

  factory MacroGoals.empty() {
    return MacroGoals(
      proteinGoal: 0,
      carbsGoal: 0,
      fatGoal: 0,
      caloriesGoal: 0,
    );
  }
}