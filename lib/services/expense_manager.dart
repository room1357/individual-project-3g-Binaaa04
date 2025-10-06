import '../models/expense.dart';

class ExpenseManager {
  static List<Expense> expenses = [/* data expenses */];

  // Total per kategori
  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    Map<String, double> result = {};
    for (var expense in expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  // Pengeluaran paling besar
  static Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  // Pengeluaran bulan tertentu
  static List<Expense> getExpensesByMonth(List<Expense> expenses, int month, int year) {
    return expenses.where((expense) => 
      expense.date.month == month && expense.date.year == year
    ).toList();
  }

  // Cari pengeluaran
  static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
    String lowerKeyword = keyword.toLowerCase();
    return expenses.where((expense) =>
      expense.title.toLowerCase().contains(lowerKeyword) ||
      expense.description.toLowerCase().contains(lowerKeyword) ||
      expense.category.toLowerCase().contains(lowerKeyword)
    ).toList();
  }

  // Rata-rata harian
  static double getAverageDaily(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    Set<String> uniqueDays = expenses.map((expense) => 
      '${expense.date.year}-${expense.date.month}-${expense.date.day}'
    ).toSet();
    
    return total / uniqueDays.length;
  }

  // Tambah data
  static void addExpense(Expense expense) {
    expenses.add(expense);
  }

  // Hapus data
  static void removeExpense(Expense expense) {
    expenses.remove(expense);
  }

  // Ubah data
  static void updateExpense(int index, Expense newExpense) {
    if (index >= 0 && index < expenses.length) {
      expenses[index] = newExpense;
    }
  }

  // Total semua pengeluaran
  static double getTotalExpense(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }
}
