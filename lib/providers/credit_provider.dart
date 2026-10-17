import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/credit_model.dart';
import '../models/credit_payment_model.dart';
import '../services/hive_service.dart';

/// Summarised view of a credit record combined with its payment history.
class CreditSummary {
  final CreditModel credit;
  final List<CreditPaymentModel> payments;

  const CreditSummary({required this.credit, required this.payments});

  /// Total amount paid/collected across all payments for this credit.
  double get totalPaid =>
      payments.fold(0.0, (sum, p) => sum + p.amount);

  /// Remaining outstanding balance.
  double get outstanding =>
      (credit.originalAmount - totalPaid).clamp(0.0, double.infinity);

  /// True when the credit is fully settled.
  bool get isSettled => outstanding <= 0;
}

class CreditProvider extends ChangeNotifier {
  List<CreditModel> _credits = [];
  List<CreditPaymentModel> _payments = [];

  CreditProvider() {
    loadData();
  }

  void loadData() {
    _credits = HiveService.getAllCredits();
    _payments = HiveService.getAllCreditPayments();
    notifyListeners();
  }

  // ── Getters ──────────────────────────────────────

  List<CreditModel> get allCredits => List.unmodifiable(_credits);
  List<CreditPaymentModel> get allPayments => List.unmodifiable(_payments);

  /// Credits where others owe the user money.
  List<CreditModel> get toReceiveCredits =>
      _credits.where((c) => c.creditType == CreditType.toReceive).toList();

  /// Credits where the user owes money to others.
  List<CreditModel> get toPayCredits =>
      _credits.where((c) => c.creditType == CreditType.toPay).toList();

  /// Build a CreditSummary for a specific credit.
  CreditSummary summaryFor(CreditModel credit) {
    final payments =
        _payments.where((p) => p.creditId == credit.id).toList();
    return CreditSummary(credit: credit, payments: payments);
  }

  /// Payments for a specific credit, sorted newest first.
  List<CreditPaymentModel> paymentsFor(String creditId) {
    return _payments
        .where((p) => p.creditId == creditId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ── Summary totals ────────────────────────────────

  double get totalOutstandingToReceive {
    return toReceiveCredits.fold(0.0, (sum, c) {
      final s = summaryFor(c);
      return sum + s.outstanding;
    });
  }

  double get totalOutstandingToPay {
    return toPayCredits.fold(0.0, (sum, c) {
      final s = summaryFor(c);
      return sum + s.outstanding;
    });
  }

  double get totalCollected {
    return toReceiveCredits.fold(0.0, (sum, c) {
      final s = summaryFor(c);
      return sum + s.totalPaid;
    });
  }

  double get totalPaidBack {
    return toPayCredits.fold(0.0, (sum, c) {
      final s = summaryFor(c);
      return sum + s.totalPaid;
    });
  }

  // ── Credit Actions ─────────────────────────────────

  Future<void> addCredit(CreditModel credit) async {
    await HiveService.saveCredit(credit);
    _credits = HiveService.getAllCredits();
    notifyListeners();
  }

  Future<void> updateCredit(CreditModel credit) async {
    await HiveService.saveCredit(credit);
    _credits = HiveService.getAllCredits();
    notifyListeners();
  }

  Future<void> deleteCredit(String id) async {
    await HiveService.deleteCredit(id);
    _credits = HiveService.getAllCredits();
    _payments = HiveService.getAllCreditPayments();
    notifyListeners();
  }

  // ── Payment Actions ───────────────────────────────

  /// Records a new payment/collection for the given credit.
  ///
  /// Returns false if [amount] exceeds the outstanding balance.
  Future<bool> recordPayment({
    required String creditId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    // Validate: find credit and compute outstanding
    final creditList = _credits.where((c) => c.id == creditId).toList();
    if (creditList.isEmpty) return false;

    final summary = summaryFor(creditList.first);
    if (amount <= 0) return false;
    if (amount > summary.outstanding + 0.001) {
      // Allow tiny float rounding tolerance
      return false;
    }

    final payment = CreditPaymentModel(
      id: const Uuid().v4(),
      creditId: creditId,
      amount: amount,
      date: date,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );

    await HiveService.savePayment(payment);
    _payments = HiveService.getAllCreditPayments();
    notifyListeners();
    return true;
  }

  Future<void> deletePayment(String paymentId) async {
    await HiveService.deletePayment(paymentId);
    _payments = HiveService.getAllCreditPayments();
    notifyListeners();
  }

  Future<void> updatePayment(CreditPaymentModel payment) async {
    await HiveService.savePayment(payment);
    _payments = HiveService.getAllCreditPayments();
    notifyListeners();
  }
}
