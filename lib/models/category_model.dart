import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
  });

  static const List<CategoryModel> expenseCategories = [
    CategoryModel(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF6B6B),
      isExpense: true,
    ),
    CategoryModel(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket_rounded,
      color: Color(0xFF10B981),
      isExpense: true,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF9B51E0),
      isExpense: true,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF3B82F6),
      isExpense: true,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF00CEC9),
      isExpense: true,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_filter_rounded,
      color: Color(0xFFF59E0B),
      isExpense: true,
    ),
    CategoryModel(
      id: 'health',
      name: 'Health & Medical',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEC4899),
      isExpense: true,
    ),
    CategoryModel(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF6366F1),
      isExpense: true,
    ),
    CategoryModel(
      id: 'travel',
      name: 'Travel & Trips',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF06B6D4),
      isExpense: true,
    ),
    CategoryModel(
      id: 'other_expense',
      name: 'Other Expense',
      icon: Icons.category_rounded,
      color: Color(0xFF64748B),
      isExpense: true,
    ),
  ];

  static const List<CategoryModel> incomeCategories = [
    CategoryModel(
      id: 'salary',
      name: 'Salary',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF10B981),
      isExpense: false,
    ),
    CategoryModel(
      id: 'freelance',
      name: 'Freelancing',
      icon: Icons.laptop_chromebook_rounded,
      color: Color(0xFF3B82F6),
      isExpense: false,
    ),
    CategoryModel(
      id: 'investments',
      name: 'Investments',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF8B5CF6),
      isExpense: false,
    ),
    CategoryModel(
      id: 'business',
      name: 'Business',
      icon: Icons.storefront_rounded,
      color: Color(0xFFF59E0B),
      isExpense: false,
    ),
    CategoryModel(
      id: 'gift',
      name: 'Gifts & Rewards',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFEC4899),
      isExpense: false,
    ),
    CategoryModel(
      id: 'other_income',
      name: 'Other Income',
      icon: Icons.attach_money_rounded,
      color: Color(0xFF14B8A6),
      isExpense: false,
    ),
  ];

  static List<CategoryModel> get allCategories => [
    ...expenseCategories,
    ...incomeCategories,
  ];

  static CategoryModel getById(String id) {
    return allCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => const CategoryModel(
        id: 'other',
        name: 'General',
        icon: Icons.bubble_chart_rounded,
        color: Color(0xFF6C5CE7),
        isExpense: true,
      ),
    );
  }
}
