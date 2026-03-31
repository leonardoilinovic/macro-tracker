import 'package:flutter/material.dart';

class FoodCategoryData {
  final String name;
  final IconData icon;
  final Color color;

  const FoodCategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<FoodCategoryData> predefinedFoodCategories = [
  FoodCategoryData(
    name: 'Meso',
    icon: Icons.set_meal,
    color: Color(0xFFFFE5E5),
  ),
  FoodCategoryData(
    name: 'Riba',
    icon: Icons.phishing,
    color: Color(0xFFE3F2FD),
  ),
  FoodCategoryData(
    name: 'Jaja',
    icon: Icons.egg_alt,
    color: Color(0xFFFFF3CD),
  ),
  FoodCategoryData(
    name: 'Mliječni proizvodi',
    icon: Icons.local_drink,
    color: Color(0xFFE8F5E9),
  ),
  FoodCategoryData(
    name: 'Riža / tjestenina',
    icon: Icons.rice_bowl,
    color: Color(0xFFFFF8E1),
  ),
  FoodCategoryData(
    name: 'Voće',
    icon: Icons.apple,
    color: Color(0xFFFFEBEE),
  ),
  FoodCategoryData(
    name: 'Povrće',
    icon: Icons.eco,
    color: Color(0xFFE8F5E9),
  ),
  FoodCategoryData(
    name: 'Grickalice',
    icon: Icons.cookie,
    color: Color(0xFFF3E5F5),
  ),
  FoodCategoryData(
    name: 'Pića',
    icon: Icons.local_cafe,
    color: Color(0xFFE1F5FE),
  ),
  FoodCategoryData(
    name: 'Dodaci',
    icon: Icons.fitness_center,
    color: Color(0xFFEDE7F6),
  ),
  FoodCategoryData(
    name: 'Ostalo',
    icon: Icons.category,
    color: Color(0xFFF5F5F5),
  ),
];