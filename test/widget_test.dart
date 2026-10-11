import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';

void main() {
  test('CategoryModel returns correct categories', () {
    expect(CategoryModel.expenseCategories.isNotEmpty, true);
    expect(CategoryModel.incomeCategories.isNotEmpty, true);
    final foodCat = CategoryModel.getById('food');
    expect(foodCat.name, 'Food & Dining');
    expect(foodCat.isExpense, true);
  });

  test('TransactionModel serialization and copyWith', () {
    final now = DateTime.now();
    final tx = TransactionModel(
      id: 'tx_123',
      title: 'Groceries',
      amount: 45.50,
      date: now,
      categoryId: 'groceries',
      isExpense: true,
      notes: 'Supermarket visit',
    );

    final map = tx.toMap();
    final fromMap = TransactionModel.fromMap(map);

    expect(fromMap.id, 'tx_123');
    expect(fromMap.title, 'Groceries');
    expect(fromMap.amount, 45.50);
    expect(fromMap.isExpense, true);
    expect(fromMap.notes, 'Supermarket visit');

    final updated = tx.copyWith(amount: 50.00);
    expect(updated.amount, 50.00);
    expect(updated.title, 'Groceries');
  });
}
