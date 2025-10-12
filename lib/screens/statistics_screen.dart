import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../utils/currency_utils.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const StatisticsScreen({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = expenses.fold(0, (sum, e) => sum + e.amount);
    double average = expenses.isNotEmpty ? total / expenses.length : 0;

    // Hitung total per kategori
    Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    // Warna untuk pie chart
    final List<Color> chartColors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Statistics',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ===== Summary Cards =====
          Wrap(
            spacing: 12, // jarak antar kartu
            runSpacing: 12, // jarak antar baris kalau pindah ke bawah
            alignment: WrapAlignment.center,
            children: [
              _buildSummaryCard('Total', formatCurrency(total)),
              _buildSummaryCard('Average', formatCurrency(average)),
              _buildSummaryCard('Items', '${expenses.length}'),
            ],
          ),
            const SizedBox(height: 20),

            // ===== Pie Chart =====
            Text('Expense by Category',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sections: List.generate(categoryTotals.length, (i) {
                    final category = categoryTotals.keys.elementAt(i);
                    final value = categoryTotals[category]!;
                    final color = chartColors[i % chartColors.length];
                    final percent = (value / total) * 100;

                    return PieChartSectionData(
                      color: color,
                      value: value,
                      title: '${percent.toStringAsFixed(1)}%',
                      radius: 70,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== List kategori + nominal =====
            ...categoryTotals.entries.map((entry) {
              final color = chartColors[
                  categoryTotals.keys.toList().indexOf(entry.key) %
                      chartColors.length];
              return ListTile(
                leading: CircleAvatar(backgroundColor: color),
                title: Text(entry.key),
                trailing: Text(formatCurrency(entry.value),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.redAccent)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Widget ringkasan
  Widget _buildSummaryCard(String title, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
