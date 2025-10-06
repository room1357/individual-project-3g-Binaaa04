import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:pemrograman_mobile/screens/category_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  final Function(Expense) onAdd;
  final List<String> categories;

  const AddExpenseScreen({super.key, required this.onAdd, required this.categories});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: _titleController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descController.text,
    );

    widget.onAdd(newExpense);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Expense"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: widget.categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : null,
              hint: const Text('Pilih Kategori'), // teks default kalau value null
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Pilih Kategori', style: TextStyle(color: Colors.grey)),
                ),
                ...widget.categories.toSet().map(
                  (cat) => DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: '__add_new__',
                  child: Text('+ Tambah Kategori', style: TextStyle(color: Colors.blue)),
                ),
              ],
              onChanged: (value) {
                if (value == '__add_new__') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(existingCategories: widget.categories),
                    ),
                  ).then((result) {
                    if (result != null) {
                      setState(() {
                        widget.categories.clear();
                        widget.categories.addAll(result.toSet()); // hapus duplikat
                        if (!widget.categories.contains(_selectedCategory)) {
                          _selectedCategory = widget.categories.first;
                        }
                      });
                    }
                  });
                } else {
                  setState(() {
                    if (value != null) {
                      _selectedCategory = value;
                    }
                  });
                }
              },
            ),

            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
