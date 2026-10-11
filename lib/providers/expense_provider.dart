import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/hive_service.dart';

enum FilterType { all, income, expense }
enum DateFilter { all, today, thisWeek, thisMonth, custom }
enum SortOption { dateDesc, dateAsc, amountDesc, amountAsc }

class CategorySpending {
  final CategoryModel category;
  final double amount;
  final double percentage;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class MonthlyStat {
  final String monthLabel;
  final int monthIndex;
  final int year;
  final double income;
  final double expense;

  const MonthlyStat({
    required this.monthLabel,
    required this.monthIndex,
    required this.year,
    required this.income,
    required this.expense,
  });
}

class ExpenseProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  double _monthlyBudget = 2500.00;
  String _currencySymbol = '₹';

  // Filter & Search states
  String _searchQuery = '';
  FilterType _filterType = FilterType.all;
  String _filterCategoryId = 'all';
  DateFilter _dateFilter = DateFilter.all;
  DateTimeRange? _customDateRange;
  SortOption _sortOption = SortOption.dateDesc;
  bool _isResetting = false;

  ExpenseProvider() {
    loadData();
  }

  void loadData() {
    _transactions = HiveService.getAllTransactions();
    _monthlyBudget = HiveService.getMonthlyBudget();
    _currencySymbol = HiveService.getCurrencySymbol();
    notifyListeners();
  }

  // Getters
  List<TransactionModel> get allTransactions => List.unmodifiable(_transactions);
  double get monthlyBudget => _monthlyBudget;
  String get currencySymbol => _currencySymbol;
  String get searchQuery => _searchQuery;
  FilterType get filterType => _filterType;
  String get filterCategoryId => _filterCategoryId;
  DateFilter get dateFilter => _dateFilter;
  DateTimeRange? get customDateRange => _customDateRange;
  SortOption get sortOption => _sortOption;
  bool get isResetting => _isResetting;

  // Formatted Currency helper
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: _currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Financial Calculations
  double get totalIncome {
    return _transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalBalance => totalIncome - totalExpense;

  // Current Month calculations
  DateTime get _now => DateTime.now();

  double get currentMonthIncome {
    return _transactions
        .where((tx) =>
            !tx.isExpense &&
            tx.date.year == _now.year &&
            tx.date.month == _now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get currentMonthExpense {
    return _transactions
        .where((tx) =>
            tx.isExpense &&
            tx.date.year == _now.year &&
            tx.date.month == _now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get budgetProgress {
    if (_monthlyBudget <= 0) return 0.0;
    return (currentMonthExpense / _monthlyBudget).clamp(0.0, 1.0);
  }

  double get remainingBudget => _monthlyBudget - currentMonthExpense;

  // Filtered Transactions
  List<TransactionModel> get filteredTransactions {
    List<TransactionModel> list = List.from(_transactions);

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((tx) {
        final titleMatch = tx.title.toLowerCase().contains(q);
        final notesMatch = tx.notes?.toLowerCase().contains(q) ?? false;
        final catMatch = tx.category.name.toLowerCase().contains(q);
        return titleMatch || notesMatch || catMatch;
      }).toList();
    }

    // Type filter
    if (_filterType == FilterType.expense) {
      list = list.where((tx) => tx.isExpense).toList();
    } else if (_filterType == FilterType.income) {
      list = list.where((tx) => !tx.isExpense).toList();
    }

    // Category filter
    if (_filterCategoryId != 'all') {
      list = list.where((tx) => tx.categoryId == _filterCategoryId).toList();
    }

    // Date filter
    final today = DateTime(_now.year, _now.month, _now.day);
    if (_dateFilter == DateFilter.today) {
      list = list.where((tx) {
        final txDay = DateTime(tx.date.year, tx.date.month, tx.date.day);
        return txDay.isAtSameMomentAs(today);
      }).toList();
    } else if (_dateFilter == DateFilter.thisWeek) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      list = list.where((tx) => tx.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) && tx.date.isBefore(weekEnd)).toList();
    } else if (_dateFilter == DateFilter.thisMonth) {
      list = list.where((tx) => tx.date.year == _now.year && tx.date.month == _now.month).toList();
    } else if (_dateFilter == DateFilter.custom && _customDateRange != null) {
      final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
      final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
      list = list.where((tx) => tx.date.isAfter(start.subtract(const Duration(seconds: 1))) && tx.date.isBefore(end)).toList();
    }

    // Sorting
    switch (_sortOption) {
      case SortOption.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return list;
  }

  // Recent 5 transactions for Dashboard
  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  // Analytics: Expense Category Breakdown
  List<CategorySpending> get categorySpendings {
    final Map<String, double> categorySums = {};
    double totalExp = 0.0;

    for (final tx in _transactions) {
      if (tx.isExpense) {
        categorySums[tx.categoryId] = (categorySums[tx.categoryId] ?? 0.0) + tx.amount;
        totalExp += tx.amount;
      }
    }

    if (totalExp == 0.0) return [];

    final list = categorySums.entries.map((entry) {
      return CategorySpending(
        category: CategoryModel.getById(entry.key),
        amount: entry.value,
        percentage: (entry.value / totalExp) * 100,
      );
    }).toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  // Analytics: Monthly Statistics for last 6 months
  List<MonthlyStat> get monthlyStats {
    final List<MonthlyStat> stats = [];
    final current = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(current.year, current.month - i, 1);
      final monthIndex = targetDate.month;
      final year = targetDate.year;
      final label = DateFormat('MMM').format(targetDate);

      double monthIncome = 0;
      double monthExpense = 0;

      for (final tx in _transactions) {
        if (tx.date.year == year && tx.date.month == monthIndex) {
          if (tx.isExpense) {
            monthExpense += tx.amount;
          } else {
            monthIncome += tx.amount;
          }
        }
      }

      stats.add(MonthlyStat(
        monthLabel: label,
        monthIndex: monthIndex,
        year: year,
        income: monthIncome,
        expense: monthExpense,
      ));
    }

    return stats;
  }

  // Actions
  Future<void> addTransaction(TransactionModel transaction) async {
    await HiveService.saveTransaction(transaction);
    _transactions = HiveService.getAllTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await HiveService.saveTransaction(transaction);
    _transactions = HiveService.getAllTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await HiveService.deleteTransaction(id);
    _transactions = HiveService.getAllTransactions();
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await HiveService.setMonthlyBudget(budget);
    notifyListeners();
  }

  Future<void> setCurrencySymbol(String symbol) async {
    _currencySymbol = symbol;
    await HiveService.setCurrencySymbol(symbol);
    notifyListeners();
  }

  /// Resets all financial data, clears stored transactions,
  /// resets budget to initial value, and refreshes all screen states.
  Future<bool> resetAppData() async {
    if (_isResetting) return false;
    _isResetting = true;
    notifyListeners();

    try {
      await HiveService.resetFinancialData();
      _transactions = HiveService.getAllTransactions();
      _monthlyBudget = HiveService.getMonthlyBudget();
      resetFilters();
      notifyListeners();
      return true;
    } catch (e, stack) {
      debugPrint('Error resetting app data: $e\n$stack');
      return false;
    } finally {
      _isResetting = false;
      notifyListeners();
    }
  }

  // Filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(FilterType type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(String categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  void setDateFilter(DateFilter filter, [DateTimeRange? range]) {
    _dateFilter = filter;
    _customDateRange = range;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _filterType = FilterType.all;
    _filterCategoryId = 'all';
    _dateFilter = DateFilter.all;
    _customDateRange = null;
    _sortOption = SortOption.dateDesc;
    notifyListeners();
  }

  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _filterType != FilterType.all ||
        _filterCategoryId != 'all' ||
        _dateFilter != DateFilter.all ||
        _sortOption != SortOption.dateDesc;
  }
}
