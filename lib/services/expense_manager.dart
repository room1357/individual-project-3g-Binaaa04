import 'package:drift/drift.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

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
  ApiService get _api => ApiService();

  Future<List<ExpenseWithCategory>> getAllExpensesWithCategory({int? userId}) async {
    List<Map<String, dynamic>> expenses;
    
    // Get expenses - filtered by userId if provided
    if (userId != null) {
      expenses = await _api.getExpensesByUserId(userId);
    } else {
      expenses = await _api.getExpenses();
    }
    
    final categories = await _api.getCategories();
    
    // Create map for category lookup
    final categoryMap = {for (var c in categories) c['categoryId']: c};
    
    return expenses.map((e) => ExpenseWithCategory(
      expenseId: e['expenseId'],
      title: e['title'],
      amount: e['amount'],
      date: DateTime.parse(e['date']),
      description: e['description'],
      categoryName: categoryMap[e['categoryId']]?['categoryName'] ?? "Uncategorized",
    )).toList();
  }

  Future<int> insertExpense(expenseTableCompanion entry) async {
    final result = await _api.createExpense(
      userId: entry.userId.value,
      title: entry.title.value,
      categoryId: entry.categoryId.value,
      amount: entry.amount.value,
      date: entry.date.value,
      description: entry.description.value,
    );
    return result?['expenseId'] ?? 0;
  }

  Future<void> deleteExpense(int id) async {
    await _api.deleteExpense(id);
  }

  Future<void> updateExpense(expenseTableCompanion entry) async {
    await _api.updateExpense(
      expenseId: entry.expenseId.value,
      userId: entry.userId.value,
      title: entry.title.value,
      categoryId: entry.categoryId.value,
      amount: entry.amount.value,
      date: entry.date.value,
      description: entry.description.value,
    );
  }
}
