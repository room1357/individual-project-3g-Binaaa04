import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/auth.dart';
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
      await database.into(database.expenseTable).insert(
        expenseTableCompanion.insert(
          title: titleController.text.trim(),
          amount: amount,
          categoryId: category.categoryId,
          date: selectedDate,
          description: descriptionController.text.trim().isEmpty
              ? '-'
              : descriptionController.text.trim(),
          userId: int.parse(user.userId.toString()),

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Add Expense')),
      body: SafeArea(
        child: isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter amount';
                          if (int.tryParse(value) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedCategoryIndex,
                              decoration:
                                  const InputDecoration(labelText: 'Category'),
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
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _openCategoryScreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            'Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isSaving ? null : _insertExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                            : const Text('Save Expense',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
