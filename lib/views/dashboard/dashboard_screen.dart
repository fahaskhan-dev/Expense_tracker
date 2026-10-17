import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../budget/set_budget_dialog.dart';
import '../transactions/add_edit_transaction_modal.dart';
import '../transactions/widgets/transaction_item_card.dart';
import 'widgets/balance_hero_card.dart';
import 'widgets/budget_progress_card.dart';
import 'widgets/income_expense_summary_row.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const DashboardScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final recentTransactions = expenseProvider.recentTransactions;
    final formattedDate = DateFormat('EEEE, MMM dd').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting & Theme Toggle Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome spendly',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBackground : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF23273E) : const Color(0xFFF1F5F9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: themeProvider.isDarkMode ? AppColors.warningAmber : AppColors.primaryPurple,
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                      tooltip: 'Toggle Theme',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Balance Card with Purple & Blue Gradient
              const BalanceHeroCard(),
              const SizedBox(height: 20),

              // Quick Actions Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionItem(
                    context: context,
                    icon: Icons.remove_circle_outline_rounded,
                    label: 'Add Expense',
                    color: AppColors.expenseRed,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const AddEditTransactionModal(initialIsExpense: true),
                      );
                    },
                    isDark: isDark,
                  ),
                  _buildQuickActionItem(
                    context: context,
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Add Income',
                    color: AppColors.incomeGreen,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const AddEditTransactionModal(initialIsExpense: false),
                      );
                    },
                    isDark: isDark,
                  ),
                  _buildQuickActionItem(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Set Budget',
                    color: AppColors.primaryPurple,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const SetBudgetDialog(),
                      );
                    },
                    isDark: isDark,
                  ),
                  _buildQuickActionItem(
                    context: context,
                    icon: Icons.insights_rounded,
                    label: 'Analytics',
                    color: AppColors.primaryBlue,
                    onTap: () => onNavigateToTab?.call(1),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Monthly Income & Expense Cards
              const IncomeExpenseSummaryRow(),
              const SizedBox(height: 20),

              // Monthly Budget Card
              const BudgetProgressCard(),
              const SizedBox(height: 26),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateToTab?.call(2),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent Transactions List
              if (recentTransactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBackground : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF23273E) : const Color(0xFFF1F5F9),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 36,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No transactions recorded yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentTransactions.map((tx) => TransactionItemCard(transaction: tx)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF23273E) : const Color(0xFFF1F5F9),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
