class MacroGoals {
  final double proteinMin;
  final double proteinMax;
  final double carbsMin;
  final double carbsMax;
  final double fatMin;
  final double fatMax;
  final double caloriesMin;
  final double caloriesMax;

  MacroGoals({
    required this.proteinMin,
    required this.proteinMax,
    required this.carbsMin,
    required this.carbsMax,
    required this.fatMin,
    required this.fatMax,
    required this.caloriesMin,
    required this.caloriesMax,
  });

  Map<String, dynamic> toJson() {
    return {
      'proteinMin': proteinMin,
      'proteinMax': proteinMax,
      'carbsMin': carbsMin,
      'carbsMax': carbsMax,
      'fatMin': fatMin,
      'fatMax': fatMax,
      'caloriesMin': caloriesMin,
      'caloriesMax': caloriesMax,
    };
  }

  factory MacroGoals.fromJson(Map<String, dynamic> json) {
    double readValue(String newKey, String oldKey) {
      final value = json[newKey] ?? json[oldKey] ?? 0;
      return (value as num).toDouble();
    }

    return MacroGoals(
      proteinMin: readValue('proteinMin', 'proteinGoal'),
      proteinMax: readValue('proteinMax', 'proteinGoal'),
      carbsMin: readValue('carbsMin', 'carbsGoal'),
      carbsMax: readValue('carbsMax', 'carbsGoal'),
      fatMin: readValue('fatMin', 'fatGoal'),
      fatMax: readValue('fatMax', 'fatGoal'),
      caloriesMin: readValue('caloriesMin', 'caloriesGoal'),
      caloriesMax: readValue('caloriesMax', 'caloriesGoal'),
    );
  }

  factory MacroGoals.empty() {
    return MacroGoals(
      proteinMin: 0,
      proteinMax: 0,
      carbsMin: 0,
      carbsMax: 0,
      fatMin: 0,
      fatMax: 0,
      caloriesMin: 0,
      caloriesMax: 0,
    );
  }
}