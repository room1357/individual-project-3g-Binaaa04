import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/expense_manager.dart';
import '../utils/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final db = AppDb();
  List<ExpenseWithCategory> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await db.getAllExpensesWithCategory();
    setState(() {
      _expenses = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f5f9),
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1e293b),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF667eea)),
              onPressed: _loadExpenses,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      _buildCategoryChart(),
                      const SizedBox(height: 24),
                      _buildDailyChart(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Add some expenses to see your spending insights',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF64748b),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalExpense = _expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final avgExpense = _expenses.isNotEmpty ? totalExpense / _expenses.length : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Expense',
                'Rp ${totalExpense.toStringAsFixed(0)}',
                Icons.account_balance_wallet_rounded,
                AppTheme.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Average',
                'Rp ${avgExpense.toStringAsFixed(0)}',
                Icons.trending_up_rounded,
                AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Transactions',
                _expenses.length.toString(),
                Icons.receipt_long_rounded,
                AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Categories',
                _categoryTotals.keys.length.toString(),
                Icons.category_rounded,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (var e in _expenses) {
      map[e.categoryName] = (map[e.categoryName] ?? 0) + e.amount.toDouble();
    }
    return map;
  }

  Widget _buildCategoryChart() {
    final totals = _categoryTotals;
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.warningColor,
      AppTheme.successColor,
      AppTheme.errorColor,
    ];
    final total = totals.values.fold(0.0, (a, b) => a + b);

    final sections = totals.entries.map((e) {
      final color = colors[totals.keys.toList().indexOf(e.key) % colors.length];
      final percent = (e.value / total) * 100;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: "${percent.toStringAsFixed(1)}%",
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Spending by Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...totals.entries.map((entry) {
            final color = colors[totals.keys.toList().indexOf(entry.key) % colors.length];
            final percent = (entry.value / total) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Rp ${entry.value.toStringAsFixed(0)} (${percent.toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  SplayTreeMap<String, double> get _dailyTotals {
    final map = <String, double>{};
    final fmt = DateFormat('dd/MM');
    for (var e in _expenses) {
      final key = fmt.format(e.date);
      map[key] = (map[key] ?? 0) + e.amount.toDouble();
    }
    return SplayTreeMap<String, double>.from(map, (a, b) => fmt.parse(a).compareTo(fmt.parse(b)));
  }

Widget _buildDailyChart() {
  final daily = _dailyTotals;
  final bars = daily.entries.map((e) {
    return BarChartGroupData(
      x: daily.keys.toList().indexOf(e.key),
      barRods: [
        BarChartRodData(
          toY: e.value,
          width: 16,
          color: AppTheme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }).toList();

  // Hitung total lebar chart
  final chartWidth = daily.length * 40.0 + 40; // 40px per bar + margin

  return Container(
    decoration: AppTheme.cardDecoration,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Daily Spending Trend",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 280,
            child: BarChart(
              BarChartData(
                maxY: daily.values.isEmpty ? 0 : daily.values.reduce((a, b) => a > b ? a : b) * 1.2,
                barGroups: bars,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < daily.length) {
                          return Text(
                            daily.keys.toList()[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        'Rp ${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Rp ${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}


