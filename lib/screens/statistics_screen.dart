import 'package:flutter/material.dart';
import '../models/expense.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const StatisticsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    double totalExpense = 0;
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      totalExpense += expense.amount;
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Expenses: Rp ${totalExpense.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: categoryTotals.entries.map((entry) {
                  double percentage = (entry.value / totalExpense) * 100;
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: LinearProgressIndicator(
                      value: entry.value / totalExpense,
                      color: Colors.blue,
                      backgroundColor: Colors.grey[300],
                    ),
                    trailing: Text('${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
