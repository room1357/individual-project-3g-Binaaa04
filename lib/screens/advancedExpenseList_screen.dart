import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:pemrograman_mobile/screens/addExpense_screen.dart';
import 'package:pemrograman_mobile/screens/category_screen.dart';
import 'package:pemrograman_mobile/screens/editExpense_screen.dart';
import 'package:pemrograman_mobile/screens/statistics_screen.dart';
import '../services/database_service.dart';
import '../services/auth.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedExpenseListScreen> createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  final AppDb database = AppDb();

  List<ExpenseWithCategory> expenses = [];
  List<ExpenseWithCategory> filteredExpenses = [];
  List<Kategori> categories = [];
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int _selectedIndex = 1;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterExpenses);

    _initializeDefaultCategories().then((_) => _loadData());
  }

  @override
  void dispose() {
    searchController.removeListener(_filterExpenses);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeDefaultCategories() async {
    final data = await database.select(database.kategory).get();
    if (data.isEmpty) {
      final defaultCategories = [
        'Food',
        'Transportation',
        'Utility',
        'Entertainment',
        'Self Care'
      ];
      final now = DateTime.now();
      for (var name in defaultCategories) {
        await database.into(database.kategory).insert(
          KategoryCompanion.insert(
            categoryName: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final auth = Provider.of<Auth>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    // Load categories terbaru
    final cats = await database.select(database.kategory).get();

    // Load expenses (join category)
    final query = database.select(database.expenseTable).join([
      drift.leftOuterJoin(
        database.kategory,
        database.kategory.categoryId
            .equalsExp(database.expenseTable.categoryId),
      ),
    ])..where(database.expenseTable.userId.equals(user.userId));

    query.orderBy([
      drift.OrderingTerm(
        expression: database.expenseTable.date,
        mode: drift.OrderingMode.desc,
      )
    ]);

    final result = await query.get();

    final expensesWithCat = result.map((row) {
      final exp = row.readTable(database.expenseTable);
      final cat = row.readTableOrNull(database.kategory);
      return ExpenseWithCategory(
        id: exp.expenseId,
        title: exp.title,
        amount: exp.amount.toDouble(),
        date: exp.date,
        description: exp.description,
        categoryName: cat?.categoryName ?? 'Uncategorized',
      );
    }).toList();

    setState(() {
      categories = cats;
      expenses = expensesWithCat;

      if (selectedCategory != 'All' &&
          !categories.any((c) => c.categoryName == selectedCategory)) {
        selectedCategory = 'All';
      }

      _filterExpenses();
      isLoading = false;
    });
  }

  void _filterExpenses() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      filteredExpenses = expenses.where((expense) {
        final matchesSearch = query.isEmpty ||
            expense.title.toLowerCase().contains(query) ||
            expense.description.toLowerCase().contains(query);
        final matchesCategory =
            selectedCategory == 'All' || expense.categoryName == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _openEditExpense(ExpenseWithCategory e) async {
    await showDialog(
      context: context,
      builder: (context) => EditExpenseScreen(
        expense: e,
        onEdit: (updatedExpense) async {
          final cat = categories.firstWhere(
            (c) => c.categoryName == updatedExpense.categoryName,
            orElse: () => categories.first,
          );
          await database.update(database.expenseTable).replace(
            expenseTableCompanion(
              expenseId: drift.Value(e.id),
              title: drift.Value(updatedExpense.title),
              amount: drift.Value(updatedExpense.amount.toInt()),
              categoryId: drift.Value(cat.categoryId),
              date: drift.Value(updatedExpense.date),
              description: drift.Value(updatedExpense.description),
              createdAt: drift.Value(e.date),
              updatedAt: drift.Value(DateTime.now()),
              userId: drift.Value(
                  Provider.of<Auth>(context, listen: false).currentUser!.userId),
            ),
          );
          await _loadData();
        },
      ),
    );
  }

  Future<void> _openCategoryManager() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );

    // jika ada perubahan, reload kategori & expenses otomatis
    if (result == true) {
      await _loadData();
    } else {
      await _loadData();
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
    return StatisticsScreen(expenses: filteredExpenses);

    } else {
      return SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalendarAppBar(
                      onDateChanged: (date) => setState(() => selectedDate = date),
                      firstDate: DateTime.now().subtract(const Duration(days: 140)),
                      lastDate: DateTime.now(),
                      selectedDate: selectedDate,
                      locale: 'en',
                      accent: Colors.blueGrey,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search your expense...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filter chips horizontal
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: selectedCategory == 'All',
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = 'All';
                                  _filterExpenses();
                                });
                              },
                            ),
                          ),
                          ...categories.map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(c.categoryName),
                                selected: selectedCategory == c.categoryName,
                                onSelected: (_) {
                                  setState(() {
                                    selectedCategory = c.categoryName;
                                    _filterExpenses();
                                  });
                                },
                              ),
                            );
                          }).toList(),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ActionChip(
                              avatar: const Icon(Icons.add),
                              label: const Text('Add Category'),
                              onPressed: _openCategoryManager,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    filteredExpenses.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No expenses found'),
                            ),
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredExpenses.length,
                            itemBuilder: (context, index) {
                              final e = filteredExpenses[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getCategoryColor(e.categoryName),
                                    child: Icon(_getCategoryIcon(e.categoryName),
                                        color: Colors.white),
                                  ),
                                  title: Text(e.title),
                                  subtitle:
                                      Text('${e.categoryName} • ${_formatDate(e.date)}'),
                                  trailing: Text(
                                    _formatCurrency(e.amount),
                                    style: TextStyle(
                                        color: Colors.red[600],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () => _openEditExpense(e),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          if (result == true) {
            await _loadData();
          } else {
            await _loadData();
          }
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Expenses',
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) => 'Rp ${amount.toStringAsFixed(0)}';
  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

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
}

class ExpenseWithCategory {
  final int id;
  final String title;
  final double amount;
  final DateTime date;
  final String description;
  final String categoryName;

  ExpenseWithCategory({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.description,
    required this.categoryName,
  });
}
