import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

class HiveService {
  static const String transactionsBoxName = 'transactions_box';
  static const String settingsBoxName = 'settings_box';

  static const String keyMonthlyBudget = 'monthly_budget';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyHasSeededData = 'has_seeded_data_v1';

  static late Box<TransactionModel> _transactionsBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    _transactionsBox = await Hive.openBox<TransactionModel>(transactionsBoxName);
    _settingsBox = await Hive.openBox<dynamic>(settingsBoxName);

    // Seed dummy demo data if this is the first launch
    final hasSeeded = _settingsBox.get(keyHasSeededData, defaultValue: false) as bool;
    if (!hasSeeded && _transactionsBox.isEmpty) {
      await _seedInitialData();
      await _settingsBox.put(keyHasSeededData, true);
    }

    // Default currency to Indian Rupee (₹)
    final existingCurrency = _settingsBox.get(keyCurrencySymbol);
    if (existingCurrency == null || existingCurrency == '\$') {
      await _settingsBox.put(keyCurrencySymbol, '₹');
    }
  }

  @visibleForTesting
  static void initBoxesForTesting({
    required Box<TransactionModel> transactionsBox,
    required Box<dynamic> settingsBox,
  }) {
    _transactionsBox = transactionsBox;
    _settingsBox = settingsBox;
  }

  static Future<void> _seedInitialData() async {
    final now = DateTime.now();
    const uuid = Uuid();

    final demoTransactions = [
      TransactionModel(
        id: uuid.v4(),
        title: 'Monthly Salary',
        amount: 4500.00,
        date: DateTime(now.year, now.month, 1),
        categoryId: 'salary',
        isExpense: false,
        notes: 'Tech Corp direct deposit',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Freelance Design Project',
        amount: 850.00,
        date: DateTime(now.year, now.month, 4),
        categoryId: 'freelance',
        isExpense: false,
        notes: 'Mobile UI redesign client payout',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Whole Foods Market',
        amount: 142.50,
        date: DateTime(now.year, now.month, now.day > 1 ? now.day - 1 : 1, 14, 30),
        categoryId: 'groceries',
        isExpense: true,
        notes: 'Fresh veggies, fruits and snacks',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Electric & Internet Bill',
        amount: 110.00,
        date: DateTime(now.year, now.month, 5),
        categoryId: 'bills',
        isExpense: true,
        notes: 'Fiber optics & power bill',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Dinner at Italian Bistro',
        amount: 68.40,
        date: DateTime(now.year, now.month, now.day, 19, 15),
        categoryId: 'food',
        isExpense: true,
        notes: 'Pasta and dessert with friends',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Uber Rides',
        amount: 32.80,
        date: DateTime(now.year, now.month, now.day > 2 ? now.day - 2 : 1, 10, 20),
        categoryId: 'transport',
        isExpense: true,
        notes: 'Airport cab & commute',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Cinema & Popcorn',
        amount: 28.00,
        date: DateTime(now.year, now.month, now.day > 3 ? now.day - 3 : 1),
        categoryId: 'entertainment',
        isExpense: true,
        notes: 'Weekend IMAX movie',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Nike Sneakers',
        amount: 120.00,
        date: DateTime(now.year, now.month, now.day > 5 ? now.day - 5 : 1),
        categoryId: 'shopping',
        isExpense: true,
        notes: 'Running sneakers purchase',
      ),
      TransactionModel(
        id: uuid.v4(),
        title: 'Gym Membership',
        amount: 55.00,
        date: DateTime(now.year, now.month, 2),
        categoryId: 'health',
        isExpense: true,
        notes: 'Monthly fitness subscription',
      ),
    ];

    for (final tx in demoTransactions) {
      await _transactionsBox.put(tx.id, tx);
    }

    await setMonthlyBudget(2500.00);
  }

  // --- Transactions CRUD ---

  static List<TransactionModel> getAllTransactions() {
    try {
      final list = _transactionsBox.values.toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }

  static Future<void> saveTransaction(TransactionModel item) async {
    await _transactionsBox.put(item.id, item);
  }

  static Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  static Future<void> clearTransactions() async {
    await _transactionsBox.clear();
  }

  /// Clears all financial records (transactions, resets budget to initial 2500.00)
  /// while preserving theme preferences and currency settings.
  static Future<void> resetFinancialData() async {
    await _transactionsBox.clear();
    await setMonthlyBudget(2500.00);
    await _settingsBox.put(keyHasSeededData, true);
  }

  // --- Settings & Preferences ---

  static double getMonthlyBudget() {
    final value = _settingsBox.get(keyMonthlyBudget, defaultValue: 2500.00);
    if (value is num) return value.toDouble();
    return 2500.00;
  }

  static Future<void> setMonthlyBudget(double budget) async {
    await _settingsBox.put(keyMonthlyBudget, budget);
  }

  static bool isDarkMode() {
    return _settingsBox.get(keyIsDarkMode, defaultValue: false) as bool;
  }

  static Future<void> setDarkMode(bool isDark) async {
    await _settingsBox.put(keyIsDarkMode, isDark);
  }

  static String getCurrencySymbol() {
    return _settingsBox.get(keyCurrencySymbol, defaultValue: '₹') as String;
  }

  static Future<void> setCurrencySymbol(String symbol) async {
    await _settingsBox.put(keyCurrencySymbol, symbol);
  }
}
