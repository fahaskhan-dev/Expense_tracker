import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/services/hive_service.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/views/main_navigation_screen.dart';
import 'package:expense_tracker/views/settings/settings_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('expense_tracker_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    final txBox = await Hive.openBox<TransactionModel>(HiveService.transactionsBoxName);
    final settingsBox = await Hive.openBox<dynamic>(HiveService.settingsBoxName);
    HiveService.initBoxesForTesting(
      transactionsBox: txBox,
      settingsBox: settingsBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('HiveService.resetFinancialData clears transactions & resets budget but preserves preferences', () async {
    // 1. Setup existing financial data & preferences
    final now = DateTime.now();
    final tx = TransactionModel(
      id: 'tx_1',
      title: 'Salary',
      amount: 5000.0,
      date: now,
      categoryId: 'salary',
      isExpense: false,
    );
    await HiveService.saveTransaction(tx);
    await HiveService.setMonthlyBudget(4000.0);
    await HiveService.setDarkMode(true);
    await HiveService.setCurrencySymbol('€');

    expect(HiveService.getAllTransactions().length, 1);
    expect(HiveService.getMonthlyBudget(), 4000.0);
    expect(HiveService.isDarkMode(), true);
    expect(HiveService.getCurrencySymbol(), '€');

    // 2. Perform reset
    await HiveService.resetFinancialData();

    // 3. Verify financial data cleared & budget reset to initial 2500.0
    expect(HiveService.getAllTransactions(), isEmpty);
    expect(HiveService.getMonthlyBudget(), 2500.0);

    // 4. Verify theme preferences and currency are preserved
    expect(HiveService.isDarkMode(), true);
    expect(HiveService.getCurrencySymbol(), '€');
  });

  test('Default currency is Indian Rupee (₹)', () {
    expect(HiveService.getCurrencySymbol(), '₹');
    final provider = ExpenseProvider();
    expect(provider.currencySymbol, '₹');
    expect(provider.formatCurrency(500), contains('₹'));
  });

  test('ExpenseProvider.resetAppData resets transactions, calculations, budget and filters', () async {
    final provider = ExpenseProvider();

    final tx = TransactionModel(
      id: 'tx_test',
      title: 'Groceries',
      amount: 150.0,
      date: DateTime.now(),
      categoryId: 'groceries',
      isExpense: true,
    );
    await provider.addTransaction(tx);
    await provider.setMonthlyBudget(3000.0);
    provider.setSearchQuery('Groc');

    expect(provider.allTransactions.length, 1);
    expect(provider.totalExpense, 150.0);
    expect(provider.totalBalance, -150.0);
    expect(provider.monthlyBudget, 3000.0);
    expect(provider.hasActiveFilters, true);

    final success = await provider.resetAppData();
    expect(success, true);

    expect(provider.allTransactions, isEmpty);
    expect(provider.totalIncome, 0.0);
    expect(provider.totalExpense, 0.0);
    expect(provider.totalBalance, 0.0);
    expect(provider.monthlyBudget, 2500.0);
    expect(provider.categorySpendings, isEmpty);
    expect(provider.recentTransactions, isEmpty);
    expect(provider.hasActiveFilters, false);
  });

  testWidgets('MainNavigationScreen has 4 tabs including Settings with Icons.settings_outlined', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all 4 navigation items exist
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pie_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Settings tab is selected and displays Settings screen
    expect(find.text('Settings'), findsWidgets); // App bar title & selected tab label
    expect(find.text('Reset App Data'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Reset App Data confirmation dialog Cancel does not clear data', (tester) async {
    final expenseProvider = ExpenseProvider();
    await tester.runAsync(() async {
      await expenseProvider.addTransaction(
        TransactionModel(
          id: 'tx_cancel_test',
          title: 'Salary',
          amount: 3000.0,
          date: DateTime.now(),
          categoryId: 'salary',
          isExpense: false,
        ),
      );
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: expenseProvider),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Reset App Data
    await tester.tap(find.text('Reset App Data'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog title, message, and buttons
    expect(find.text('Reset App Data?'), findsOneWidget);
    expect(
      find.text('This will permanently clear your financial records. This action cannot be undone.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Reset Everything'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog dismissed and data preserved
    expect(find.text('Reset App Data?'), findsNothing);
    expect(expenseProvider.allTransactions.length, 1);
  });

  testWidgets('Reset App Data confirmation dialog Confirm dismisses dialog and initiates reset', (tester) async {
    final expenseProvider = ExpenseProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: expenseProvider),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Reset App Data
    await tester.tap(find.text('Reset App Data'));
    await tester.pumpAndSettle();

    expect(find.text('Reset App Data?'), findsOneWidget);
    expect(find.text('Reset Everything'), findsOneWidget);

    // Tap Reset Everything
    await tester.tap(find.text('Reset Everything'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Dialog dismissed
    expect(find.text('Reset App Data?'), findsNothing);

    // Clear active SnackBars so no timer remains pending
    final scaffoldMessenger = tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger));
    scaffoldMessenger.clearSnackBars();
    await tester.pump();
  });
}
