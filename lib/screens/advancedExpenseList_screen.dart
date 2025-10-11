import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/addExpense_screen.dart';
import 'package:pemrograman_mobile/screens/category_screen.dart';
import 'package:pemrograman_mobile/screens/editExpense_screen.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();

  List<String> categories = [
    'All',
    'Food',
    'Transportation',
    'Utility',
    'Entertainment',
    'Self Care',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await StorageService.instance.getExpenses();
    setState(() {
      expenses = data;
      filteredExpenses = expenses; // tampilkan semua pengeluaran
    });
  }

  void _openCategoryManager() async {
    final updatedCategories = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(existingCategories: categories),
      ),
    );

    if (updatedCategories != null && updatedCategories is List<String>) {
      setState(() {
        categories = updatedCategories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Expense List', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          CalendarAppBar(
            onDateChanged: (value) => print(value),
            firstDate: DateTime.now().subtract(Duration(days: 140)),
            lastDate: DateTime.now(),
            selectedDate: DateTime.now(),
            locale: 'en',
            accent: Colors.blueGrey,
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search your expense...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterExpenses();
              },
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                // ✅ Filter kategori + tombol tambah kategori
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...categories.map((category) => Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: selectedCategory == category,
                              onSelected: (selected) {
                                setState(() => selectedCategory = category);
                                _filterExpenses();
                              },
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: ActionChip(
                          avatar: Icon(Icons.add),
                          label: Text('Add Category'),
                          onPressed: _openCategoryManager,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                          'Total', _calculateTotal(filteredExpenses)),
                      _buildStatCard(
                          'Amount', '${filteredExpenses.length} item'),
                      _buildStatCard(
                          'Average', _calculateAverage(filteredExpenses)),
                    ],
                  ),
                ),

                if (filteredExpenses.isEmpty)
                  Center(child: Text('No expenses found'))
                else
                  ...filteredExpenses.map((expense) => Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getCategoryColor(expense.category),
                            child: Icon(
                              _getCategoryIcon(expense.category),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(expense.title),
                          subtitle:
                              Text('${expense.category} • ${expense.formattedDate}'),
                          trailing: Text(
                            expense.formattedAmount,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600]),
                          ),
                          onTap: () => _showExpenseDetails(context, expense),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(categories: categories),
            ),
          );

          if (newExpense != null && newExpense is Expense) {
            setState(() {
              expenses.add(newExpense); // tambah ke list utama saja
              _filterExpenses(); // update filteredExpenses otomatis
            });

            // Save langsung ke storage
            await StorageService.instance.saveExpenses(expenses);
          }
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.home)),
            SizedBox(width: 20),
            IconButton(
              onPressed: () async {
                final existingCategories =
                    expenses.map((e) => e.category).toSet().toList();
                final category = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryScreen(existingCategories: existingCategories),
                  ),
                );
                if (category != null) {
                  print('Kategori terpilih: $category');
                }
              },
              icon: Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }

  void _filterExpenses() {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        bool matchesSearch = searchController.text.isEmpty ||
            expense.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            expense.description
                .toLowerCase()
                .contains(searchController.text.toLowerCase());

        bool matchesCategory =
            selectedCategory == 'All' || expense.category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 'Rp 0';
    double average =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount) /
            expenses.length;
    return 'Rp ${average.toStringAsFixed(0)}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.redAccent;
      case 'Transportation':
        return Colors.blueAccent;
      case 'Utility':
        return Colors.orangeAccent;
      case 'Entertainment':
        return Colors.green;
      case 'Self Care':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Transportation':
        return Icons.directions_car;
      case 'Utility':
        return Icons.lightbulb;
      case 'Entertainment':
        return Icons.movie;
      case 'Self Care':
        return Icons.spa;
      default:
        return Icons.category;
    }
  }

void _showExpenseDetails(BuildContext context, Expense expense) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              expense.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Category: ${expense.category}'),
            SizedBox(height: 8),
            Text('Date: ${expense.formattedDate}'),
            SizedBox(height: 8),
            Text('Total: ${expense.formattedAmount}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red[600])),
            SizedBox(height: 8),
            Text('Description: ${expense.description}'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => EditExpenseScreen(
                        expense: expense,
                        categories: categories,
                        onEdit: (updatedExpense) async {
                          setState(() {
                            final index = expenses
                                .indexWhere((e) => e.id == updatedExpense.id);
                            if (index != -1) expenses[index] = updatedExpense;
                            _filterExpenses();
                          });
                          await StorageService.instance.saveExpenses(expenses);
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                  label: Text('Close'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
}
