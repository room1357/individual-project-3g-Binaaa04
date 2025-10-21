import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import '../services/database_service.dart';
import '../services/expense_manager.dart';
import '../services/auth.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import 'addExpense_screen.dart';
import 'category_screen.dart';
import 'editExpense_screen.dart';
import 'statistics_screen.dart';

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

    final cats = await database.select(database.kategory).get();
    final allExpenses = await database.getAllExpensesWithCategory();

    // Filter by userId kalau perlu
    final userExpenses = allExpenses.where((e) => true).toList();

    setState(() {
      categories = cats;
      expenses = userExpenses;
      filteredExpenses = userExpenses;
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
        categories: categories,
        onEdit: (updatedExpense) async {
          final cat = categories.firstWhere(
            (c) => c.categoryName == updatedExpense.categoryName,
            orElse: () => categories.first,
          );

          await database.updateExpense(
            expenseTableCompanion(
              expenseId: drift.Value(e.expenseId),
              title: drift.Value(updatedExpense.title),
              amount: drift.Value(updatedExpense.amount),
              categoryId: drift.Value(cat.categoryId),
              date: drift.Value(updatedExpense.date),
              description: drift.Value(updatedExpense.description),
              updatedAt: drift.Value(DateTime.now()),
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

    if (result == true) await _loadData();
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _buildCategoryChip(String name) {
    final isSelected = selectedCategory == name;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedCategory = name;
            _filterExpenses();
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBody: true,
      body: _selectedIndex == 0
          ? const StatisticsScreen()
          : SafeArea(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCalendarHeader(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildCategoryFilter(),
                          const SizedBox(height: 16),
                          _buildExpensesList(),
                        ],
                      ),
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          if (result == true) await _loadData();
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondary,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              iconSize: 24,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_rounded),
                  label: 'Statistics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_rounded),
                  label: 'Expenses',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CalendarAppBar(
        onDateChanged: (date) => setState(() => selectedDate = date),
        firstDate: DateTime.now().subtract(const Duration(days: 140)),
        lastDate: DateTime.now(),
        selectedDate: selectedDate,
        locale: 'en',
        accent: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: filteredExpenses.isEmpty
                  ? null
                  : () async {
                      final file = await PdfService.exportExpenses(filteredExpenses);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            file == null
                                ? 'Storage permission denied'
                                : 'PDF saved to: ${file.path}',
                          ),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    },
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Export PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _openCategoryManager,
              icon: const Icon(Icons.category_rounded),
              label: const Text('Categories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search your expenses...',
            prefixIcon: Icon(Icons.search_rounded),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All'),
          ...categories.map((c) => _buildCategoryChip(c.categoryName)),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Category'),
              onPressed: _openCategoryManager,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    if (filteredExpenses.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No Expenses Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or add a new expense',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = filteredExpenses[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: AppTheme.cardDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.categoryName).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(expense.categoryName),
                color: _getCategoryColor(expense.categoryName),
                size: 24,
              ),
            ),
            title: Text(
              expense.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  expense.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(expense.categoryName).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        expense.categoryName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getCategoryColor(expense.categoryName),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(expense.date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(expense.amount),
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
            onTap: () => _openEditExpense(expense),
          ),
        );
      },
    );
  }

  String _formatCurrency(int amount) => 'Rp $amount';
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

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
