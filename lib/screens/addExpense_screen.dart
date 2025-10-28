import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/services/expense_manager.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/auth.dart';
import '../utils/app_theme.dart';
import 'category_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final AppDb database = AppDb();
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  List<String> categories = [];
  int? selectedCategoryIndex;
  DateTime selectedDate = DateTime.now();

  bool isLoadingCategories = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi kategori default lalu load kategori
    database.initializeDefaultCategories().then((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    setState(() => isLoadingCategories = true);
    try {
      final data = await database.select(database.kategory).get();
      setState(() {
        categories = data.map((c) => c.categoryName).toList();
        if (categories.isNotEmpty && selectedCategoryIndex == null) {
          selectedCategoryIndex = 0;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    } finally {
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> _insertExpense() async {
    final auth = Provider.of<Auth>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    if (!_formKey.currentState!.validate() || selectedCategoryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final categoryName = categories[selectedCategoryIndex!];
      final categoryList = await database.select(database.kategory).get();
      final category = categoryList.firstWhere(
        (c) => c.categoryName == categoryName,
        orElse: () => throw Exception('Category not found'),
      );

      final amountText = amountController.text.trim();
      final amount = int.tryParse(amountText);
      if (amount == null) throw Exception('Amount must be a number');

      final now = DateTime.now();
      
      // Insert using API instead of local database
      await database.insertExpense(
        expenseTableCompanion.insert(
          title: titleController.text.trim(),
          amount: amount,
          categoryId: category.categoryId,
          date: selectedDate,
          description: descriptionController.text.trim().isEmpty
              ? '-'
              : descriptionController.text.trim(),
          userId: user.userId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save expense: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _openCategoryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );
    if (result == true) {
      await _loadCategories();
      setState(() {
        selectedCategoryIndex = categories.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f5f9),
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1e293b),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryColor),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildExpenseForm(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.add_circle_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Expense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track your spending easily',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Expense Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title_rounded),
                hintText: 'Enter expense title',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money_rounded),
                hintText: 'Enter amount',
                prefixText: 'Rp ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                if (int.tryParse(value) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedCategoryIndex,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: categories.asMap().entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCategoryIndex = value),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: AppTheme.accentColor),
                    onPressed: _openCategoryScreen,
                    tooltip: 'Add Category',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${selectedDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_rounded),
                hintText: 'Enter description (optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _insertExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Expense',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
