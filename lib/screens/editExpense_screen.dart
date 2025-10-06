import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:pemrograman_mobile/screens/category_screen.dart';

class EditExpenseScreen extends StatefulWidget {
  final Function(Expense) onEdit;
  final Expense expense;
    final List<String> categories;

  const EditExpenseScreen({super.key, required this.onEdit, required this.expense,required this.categories});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _descController = TextEditingController(text: widget.expense.description);
    _selectedCategory = widget.expense.category; 
    _selectedDate = widget.expense.date; 
  }
  void editData(){

  }
    late String _selectedCategory;
    late DateTime _selectedDate;


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

    widget.onEdit(newExpense);
    Navigator.pop(context);
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