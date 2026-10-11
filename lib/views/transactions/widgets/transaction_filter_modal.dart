import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/category_model.dart';
import '../../../providers/expense_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/gradient_button.dart';

class TransactionFilterModal extends StatefulWidget {
  const TransactionFilterModal({super.key});

  @override
  State<TransactionFilterModal> createState() => _TransactionFilterModalState();
}

class _TransactionFilterModalState extends State<TransactionFilterModal> {
  late FilterType _selectedType;
  late String _selectedCategoryId;
  late DateFilter _selectedDateFilter;
  late SortOption _selectedSortOption;
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ExpenseProvider>();
    _selectedType = provider.filterType;
    _selectedCategoryId = provider.filterCategoryId;
    _selectedDateFilter = provider.dateFilter;
    _selectedSortOption = provider.sortOption;
    _customDateRange = provider.customDateRange;
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedDateFilter = DateFilter.custom;
      });
    }
  }

  void _apply() {
    final provider = context.read<ExpenseProvider>();
    provider.setFilterType(_selectedType);
    provider.setFilterCategory(_selectedCategoryId);
    provider.setDateFilter(_selectedDateFilter, _customDateRange);
    provider.setSortOption(_selectedSortOption);
    Navigator.of(context).pop();
  }

  void _reset() {
    final provider = context.read<ExpenseProvider>();
    provider.resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = CategoryModel.allCategories;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset All'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Transaction Type
              _buildSectionHeader('Transaction Type', isDark),
              Wrap(
                spacing: 8,
                children: [
                  _buildChoiceChip(
                    'All Types',
                    _selectedType == FilterType.all,
                    () => setState(() => _selectedType = FilterType.all),
                    isDark,
                  ),
                  _buildChoiceChip(
                    'Expenses Only',
                    _selectedType == FilterType.expense,
                    () => setState(() => _selectedType = FilterType.expense),
                    isDark,
                    color: AppColors.expenseRed,
                  ),
                  _buildChoiceChip(
                    'Income Only',
                    _selectedType == FilterType.income,
                    () => setState(() => _selectedType = FilterType.income),
                    isDark,
                    color: AppColors.incomeGreen,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Period
              _buildSectionHeader('Date Period', isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChoiceChip(
                    'All Time',
                    _selectedDateFilter == DateFilter.all,
                    () => setState(() => _selectedDateFilter = DateFilter.all),
                    isDark,
                  ),
                  _buildChoiceChip(
                    'Today',
                    _selectedDateFilter == DateFilter.today,
                    () => setState(() => _selectedDateFilter = DateFilter.today),
                    isDark,
                  ),
                  _buildChoiceChip(
                    'This Week',
                    _selectedDateFilter == DateFilter.thisWeek,
                    () => setState(() => _selectedDateFilter = DateFilter.thisWeek),
                    isDark,
                  ),
                  _buildChoiceChip(
                    'This Month',
                    _selectedDateFilter == DateFilter.thisMonth,
                    () => setState(() => _selectedDateFilter = DateFilter.thisMonth),
                    isDark,
                  ),
                  _buildChoiceChip(
                    _customDateRange != null
                        ? '${DateFormat('MM/dd').format(_customDateRange!.start)} - ${DateFormat('MM/dd').format(_customDateRange!.end)}'
                        : 'Custom Range',
                    _selectedDateFilter == DateFilter.custom,
                    _pickCustomDateRange,
                    isDark,
                    icon: Icons.date_range_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sort Option
              _buildSectionHeader('Sort By', isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChoiceChip(
                    'Newest First',
                    _selectedSortOption == SortOption.dateDesc,
                    () => setState(() => _selectedSortOption = SortOption.dateDesc),
                    isDark,
                  ),
                  _buildChoiceChip(
                    'Oldest First',
                    _selectedSortOption == SortOption.dateAsc,
                    () => setState(() => _selectedSortOption = SortOption.dateAsc),
                    isDark,
                  ),
                  _buildChoiceChip(
                    'Highest Amount',
                    _selectedSortOption == SortOption.amountDesc,
                    () => setState(() => _selectedSortOption = SortOption.amountDesc),
                    isDark,
                  ),
                  _buildChoiceChip(
                    'Lowest Amount',
                    _selectedSortOption == SortOption.amountAsc,
                    () => setState(() => _selectedSortOption = SortOption.amountAsc),
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category Filter
              _buildSectionHeader('Category', isDark),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildChoiceChip(
                      'All Categories',
                      _selectedCategoryId == 'all',
                      () => setState(() => _selectedCategoryId = 'all'),
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((cat) {
                      final isSelected = _selectedCategoryId == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildChoiceChip(
                          cat.name,
                          isSelected,
                          () => setState(() => _selectedCategoryId = cat.id),
                          isDark,
                          icon: cat.icon,
                          color: cat.color,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Apply button
              GradientButton(
                text: 'Apply Filters',
                onPressed: _apply,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark, {
    Color? color,
    IconData? icon,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
