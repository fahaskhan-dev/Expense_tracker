import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state_view.dart';
import 'add_edit_transaction_modal.dart';
import 'widgets/transaction_filter_modal.dart';
import 'widgets/transaction_item_card.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredList = provider.filteredTransactions;
    final hasFilters = provider.hasActiveFilters;

    // Calculate sum of currently displayed transactions
    double sum = 0;
    for (final tx in filteredList) {
      if (tx.isExpense) {
        sum -= tx.amount;
      } else {
        sum += tx.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            tooltip: 'Filter transactions',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list_rounded),
                if (hasFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const TransactionFilterModal(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Quick Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by title, category, notes...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => provider.setSearchQuery(''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Type Filter Chips Row
                Row(
                  children: [
                    _buildQuickTypeChip(
                      label: 'All',
                      isSelected: provider.filterType == FilterType.all,
                      onTap: () => provider.setFilterType(FilterType.all),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickTypeChip(
                      label: 'Expenses',
                      isSelected: provider.filterType == FilterType.expense,
                      onTap: () => provider.setFilterType(FilterType.expense),
                      isDark: isDark,
                      color: AppColors.expenseRed,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickTypeChip(
                      label: 'Income',
                      isSelected: provider.filterType == FilterType.income,
                      onTap: () => provider.setFilterType(FilterType.income),
                      isDark: isDark,
                      color: AppColors.incomeGreen,
                    ),
                    const Spacer(),
                    if (hasFilters)
                      GestureDetector(
                        onTap: () => provider.resetFilters(),
                        child: Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.primaryPurple,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Count and Net Filtered Amount header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredList.length} Transactions found',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  'Net: ${provider.formatCurrency(sum)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sum >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
                  ),
                ),
              ],
            ),
          ),

          // Transactions List or Empty State
          Expanded(
            child: filteredList.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Transactions Found',
                    message: hasFilters
                        ? 'Try clearing your search query or adjusting your filters.'
                        : 'Tap the + button to add your first transaction.',
                    buttonText: hasFilters ? 'Reset Filters' : 'Add Transaction',
                    onButtonPressed: () {
                      if (hasFilters) {
                        provider.resetFilters();
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddEditTransactionModal(),
                        );
                      }
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return TransactionItemCard(transaction: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.primaryPurple;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : (isDark ? AppColors.darkCardBackground : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }
}
