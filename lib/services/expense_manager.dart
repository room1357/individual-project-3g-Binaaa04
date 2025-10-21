import 'package:drift/drift.dart';
import '../services/database_service.dart';

class ExpenseWithCategory {
  final int expenseId;
  final String title;
  final int amount;
  final DateTime date;
  final String description;
  final String categoryName;

  ExpenseWithCategory({
    required this.expenseId,
    required this.title,
    required this.amount,
    required this.date,
    required this.description,
    required this.categoryName,
  });
}

extension ExpenseManager on AppDb {
  Future<List<ExpenseWithCategory>> getAllExpensesWithCategory() async {
    final query = select(expenseTable).join([
      leftOuterJoin(
        kategory,
        kategory.categoryId.equalsExp(expenseTable.categoryId),
      ),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      final expense = row.readTable(expenseTable);
      final category = row.readTableOrNull(kategory);
      return ExpenseWithCategory(
        expenseId: expense.expenseId,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        description: expense.description,
        categoryName: category?.categoryName ?? "Uncategorized",
      );
    }).toList();
  }

  Future<int> insertExpense(expenseTableCompanion entry) =>
      into(expenseTable).insert(entry);

  Future<void> deleteExpense(int id) async {
    await (delete(expenseTable)..where((tbl) => tbl.expenseId.equals(id))).go();
  }

  Future<void> updateExpense(expenseTableCompanion entry) async {
    await update(expenseTable).replace(entry);
  }
}
