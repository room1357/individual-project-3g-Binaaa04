import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/advancedExpenseList_screen.dart';
import 'package:pemrograman_mobile/screens/category_screen.dart';
import '../services/database_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Function(ExpenseWithCategory) onEdit;
  final ExpenseWithCategory expense;

  const EditExpenseScreen({
    super.key,
    required this.onEdit,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final AppDb database = AppDb();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _descController = TextEditingController(text: widget.expense.description);
    _selectedCategory = widget.expense.categoryName;
    _selectedDate = widget.expense.date;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await database.select(database.kategory).get();
    setState(() {
      categories = data.map((c) => c.categoryName).toList();

      // Jika kategori expense yang diedit tidak ada (misal dihapus), tambahkan sementara
      if (!categories.contains(_selectedCategory)) {
        categories.insert(0, _selectedCategory);
      }
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _openCategoryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );

    if (result == true) {
      // Refresh kategori jika ada penambahan
      await _loadCategories();
      setState(() {
        _selectedCategory = categories.last; // pilih kategori terbaru
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final updatedExpense = ExpenseWithCategory(
      id: widget.expense.id,
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      date: _selectedDate,
      description: _descController.text.trim(),
      categoryName: _selectedCategory,
    );

    widget.onEdit(updatedExpense);
    Navigator.pop(context, true); // pop true supaya AdvancedExpenseList refresh
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Expense"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedCategory = value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _openCategoryScreen,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                      "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text(
                    "Pick Date",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
