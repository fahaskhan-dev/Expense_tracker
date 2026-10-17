import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/credit_model.dart';
import '../../models/credit_payment_model.dart';
import '../../providers/credit_provider.dart';
import '../../theme/app_colors.dart';
import 'add_edit_credit_modal.dart';
import 'record_payment_modal.dart';

class CreditDetailScreen extends StatelessWidget {
  final String creditId;
  final CreditModel? initialCredit;

  const CreditDetailScreen({
    super.key,
    required this.creditId,
    this.initialCredit,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreditProvider>();

    final latest = provider.allCredits
        .where((c) => c.id == creditId)
        .cast<CreditModel?>()
        .firstOrNull;

    final credit = latest ?? initialCredit;

    if (credit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Credit Details')),
        body: const Center(
          child: Text(
            'Credit record not found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final summary = provider.summaryFor(credit);
    final isToReceive = credit.creditType == CreditType.toReceive;

    return _CreditDetailView(
      credit: credit,
      summary: summary,
      isToReceive: isToReceive,
    );
  }
}

class _CreditDetailView extends StatelessWidget {
  final CreditModel credit;
  final CreditSummary summary;
  final bool isToReceive;

  const _CreditDetailView({
    required this.credit,
    required this.summary,
    required this.isToReceive,
  });

  Color get _typeColor =>
      isToReceive ? AppColors.incomeGreen : AppColors.expenseRed;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Credit Record?'),
        content: Text(
          'Delete credit record for "${credit.personName}"?\nAll associated payment history will also be deleted. This cannot be undone.',
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
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final personName = credit.personName;
              final provider = context.read<CreditProvider>();

              Navigator.of(dialogCtx).pop();
              nav.pop();
              provider.deleteCredit(credit.id);

              messenger.showSnackBar(
                SnackBar(
                  content: Text('Deleted credit for "$personName"'),
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

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditCreditModal(credit: credit),
    );
  }

  void _openRecordPayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecordPaymentModal(
        credit: credit,
        outstandingBalance: summary.outstanding,
      ),
    );
  }

  void _confirmDeletePayment(
      BuildContext context, CreditPaymentModel payment) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Payment?'),
        content: Text(
          'Delete this payment of ₹${payment.amount.toStringAsFixed(2)} on ${DateFormat('MMM dd, yyyy').format(payment.date)}?',
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
              context.read<CreditProvider>().deletePayment(payment.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment deleted and balance recalculated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final payments = summary.payments
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          credit.personName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_rounded, size: 22),
            color: AppColors.primaryPurple,
            onPressed: () => _openEdit(context),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            color: AppColors.expenseRed,
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Balance Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isToReceive
                    ? AppColors.incomeGradient
                    : AppColors.expenseGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _typeColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isToReceive ? 'Money to Receive' : 'Money to Pay',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (summary.isSettled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✅ Settled',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${summary.outstanding.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Outstanding Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: credit.originalAmount > 0
                          ? (summary.totalPaid / credit.originalAmount)
                              .clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Original / Paid / Outstanding row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeroStat(
                        label: 'Original',
                        value:
                            '₹${credit.originalAmount.toStringAsFixed(2)}',
                      ),
                      _HeroStat(
                        label: isToReceive ? 'Collected' : 'Paid',
                        value:
                            '₹${summary.totalPaid.toStringAsFixed(2)}',
                        align: TextAlign.center,
                      ),
                      _HeroStat(
                        label: 'Remaining',
                        value:
                            '₹${summary.outstanding.toStringAsFixed(2)}',
                        align: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Credit Info Card ──
            _buildInfoCard(context, isDark),
            const SizedBox(height: 20),

            // ── Record Payment Button ──
            if (!summary.isSettled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openRecordPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _typeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Icon(
                    isToReceive
                        ? Icons.download_rounded
                        : Icons.upload_rounded,
                    size: 20,
                  ),
                  label: Text(
                    isToReceive ? 'Record Collection' : 'Record Payment',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.incomeGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.incomeGreen.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Text(
                    '✅  This credit is fully settled',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.incomeGreen,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // ── Payment History ──
            Text(
              'Payment History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 12),

            if (payments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF23273E)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 36,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No payment history yet',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...payments.map(
                (p) => _PaymentHistoryCard(
                  payment: p,
                  isToReceive: isToReceive,
                  isDark: isDark,
                  onDelete: () => _confirmDeletePayment(context, p),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF23273E) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (credit.phoneNumber != null && credit.phoneNumber!.isNotEmpty)
            ..._infoRow(
              isDark: isDark,
              icon: Icons.phone_outlined,
              iconColor: AppColors.primaryBlue,
              label: 'Phone',
              value: credit.phoneNumber!,
            ),
          ..._infoRow(
            isDark: isDark,
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.primaryPurple,
            label: 'Date',
            value: DateFormat('EEEE, MMMM dd, yyyy').format(credit.date),
          ),
          if (credit.dueDate != null)
            ..._infoRow(
              isDark: isDark,
              icon: Icons.event_rounded,
              iconColor: AppColors.warningAmber,
              label: 'Due Date',
              value:
                  DateFormat('EEEE, MMMM dd, yyyy').format(credit.dueDate!),
            ),
          if (credit.description != null && credit.description!.isNotEmpty)
            ..._infoRow(
              isDark: isDark,
              icon: Icons.description_outlined,
              iconColor: AppColors.accentViolet,
              label: 'Description',
              value: credit.description!,
              isMultiLine: true,
            ),
          if (credit.notes != null && credit.notes!.isNotEmpty)
            ..._infoRow(
              isDark: isDark,
              icon: Icons.note_alt_outlined,
              iconColor: AppColors.warningAmber,
              label: 'Notes',
              value: credit.notes!,
              isMultiLine: true,
              isLast: true,
            ),
        ],
      ),
    );
  }

  List<Widget> _infoRow({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isMultiLine = false,
    bool isLast = false,
  }) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          crossAxisAlignment:
              isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        Divider(
          height: 1,
          indent: 56,
          endIndent: 18,
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
    ];
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final TextAlign align;

  const _HeroStat({
    required this.label,
    required this.value,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : align == TextAlign.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  final CreditPaymentModel payment;
  final bool isToReceive;
  final bool isDark;
  final VoidCallback onDelete;

  const _PaymentHistoryCard({
    required this.payment,
    required this.isToReceive,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isToReceive ? AppColors.incomeGreen : AppColors.expenseRed;
    final dateFormatted =
        DateFormat('MMM dd, yyyy • hh:mm a').format(payment.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF23273E) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isToReceive
                  ? Icons.download_rounded
                  : Icons.upload_rounded,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${payment.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
                if (payment.note != null && payment.note!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    payment.note!,
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
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            onPressed: onDelete,
            tooltip: 'Delete payment',
          ),
        ],
      ),
    );
  }
}
