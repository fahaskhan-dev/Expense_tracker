import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/credit_model.dart';
import '../../providers/credit_provider.dart';
import '../../theme/app_colors.dart';
import 'add_edit_credit_modal.dart';
import 'credit_detail_screen.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddCredit({CreditType? type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditCreditModal(initialType: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<CreditProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
        actions: [
          IconButton(
            tooltip: 'Add credit record',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openAddCredit(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To Receive'),
            Tab(text: 'To Pay'),
          ],
          labelColor: AppColors.primaryPurple,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorColor: AppColors.primaryPurple,
          indicatorWeight: 3,
        ),
      ),
      body: Column(
        children: [
          // ── Summary Cards Row ──
          _SummaryRow(provider: provider, isDark: isDark),

          // ── Tab Content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CreditListView(
                  credits: provider.toReceiveCredits,
                  provider: provider,
                  isDark: isDark,
                  isToReceive: true,
                  onAddTap: () => _openAddCredit(type: CreditType.toReceive),
                ),
                _CreditListView(
                  credits: provider.toPayCredits,
                  provider: provider,
                  isDark: isDark,
                  isToReceive: false,
                  onAddTap: () => _openAddCredit(type: CreditType.toPay),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () => _openAddCredit(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

// ─── Summary Row ─────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final CreditProvider provider;
  final bool isDark;

  const _SummaryRow({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'To Receive',
              value: provider.totalOutstandingToReceive,
              color: AppColors.incomeGreen,
              icon: Icons.arrow_downward_rounded,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'To Pay',
              value: provider.totalOutstandingToPay,
              color: AppColors.expenseRed,
              icon: Icons.arrow_upward_rounded,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'Collected',
              value: provider.totalCollected,
              color: AppColors.primaryPurple,
              icon: Icons.download_done_rounded,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'Paid Back',
              value: provider.totalPaidBack,
              color: AppColors.primaryBlue,
              icon: Icons.check_circle_outline_rounded,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF23273E) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            '₹${_fmt(value)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(1)}L';
    } else if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }
}

// ─── Credit List View ──────────────────────────────────

class _CreditListView extends StatelessWidget {
  final List<CreditModel> credits;
  final CreditProvider provider;
  final bool isDark;
  final bool isToReceive;
  final VoidCallback onAddTap;

  const _CreditListView({
    required this.credits,
    required this.provider,
    required this.isDark,
    required this.isToReceive,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    if (credits.isEmpty) {
      return _EmptyState(
        isToReceive: isToReceive,
        isDark: isDark,
        onAddTap: onAddTap,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: credits.length,
      itemBuilder: (context, index) {
        final credit = credits[index];
        final summary = provider.summaryFor(credit);
        return _CreditItemCard(
          credit: credit,
          summary: summary,
          isDark: isDark,
          isToReceive: isToReceive,
          onDelete: () => _confirmDelete(context, credit),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CreditModel credit) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Credit Record?'),
        content: Text(
          'Delete credit for "${credit.personName}"? All payment history will be deleted too.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<CreditProvider>().deleteCredit(credit.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted credit for "${credit.personName}"'),
                  backgroundColor: AppColors.expenseRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Credit Item Card ─────────────────────────────────

class _CreditItemCard extends StatelessWidget {
  final CreditModel credit;
  final CreditSummary summary;
  final bool isDark;
  final bool isToReceive;
  final VoidCallback onDelete;

  const _CreditItemCard({
    required this.credit,
    required this.summary,
    required this.isDark,
    required this.isToReceive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isToReceive ? AppColors.incomeGreen : AppColors.expenseRed;
    final dateFormatted = DateFormat('MMM dd, yyyy').format(credit.date);
    final progressValue = credit.originalAmount > 0
        ? (summary.totalPaid / credit.originalAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreditDetailScreen(creditId: credit.id),
              ),
            );
          },
          onLongPress: onDelete,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          credit.personName.isNotEmpty
                              ? credit.personName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  credit.personName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (summary.isSettled)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.incomeGreen
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Settled',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.incomeGreen,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dateFormatted,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${summary.outstanding.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: summary.isSettled ? Colors.grey : color,
                          ),
                        ),
                        Text(
                          'of ₹${credit.originalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Progress bar
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor:
                        color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5,
                  ),
                ),

                if (credit.description != null &&
                    credit.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    credit.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isToReceive;
  final bool isDark;
  final VoidCallback onAddTap;

  const _EmptyState({
    required this.isToReceive,
    required this.isDark,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isToReceive
                    ? AppColors.incomeGreen.withValues(alpha: 0.1)
                    : AppColors.expenseRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isToReceive
                    ? Icons.account_balance_wallet_outlined
                    : Icons.payments_outlined,
                size: 48,
                color: isToReceive
                    ? AppColors.incomeGreen
                    : AppColors.expenseRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isToReceive
                  ? 'No Money to Receive'
                  : 'No Money to Pay',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isToReceive
                  ? 'Track money others owe you. Tap + to add a record.'
                  : 'Track money you owe others. Tap + to add a record.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isToReceive
                    ? AppColors.incomeGreen
                    : AppColors.expenseRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                isToReceive ? 'Add Money to Receive' : 'Add Money to Pay',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
