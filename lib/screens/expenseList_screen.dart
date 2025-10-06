import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'addExpense_screen.dart';
import 'editExpense_screen.dart';
import '../services/expense_manager.dart'; 


class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final List<Expense> expenses = [
    Expense(
      id: '1',
      title: 'Monthly Shopping',
      amount: 150000,
      category: 'Food',
      date: DateTime(2024, 9, 15),
      description: 'Monthly groceries at the supermarket',
    ),
    Expense(
      id: '2',
      title: 'Motorbike Fuel',
      amount: 50000,
      category: 'Transportation',
      date: DateTime(2024, 9, 14),
      description: 'Fuel for daily commute',
    ),
          Expense(
        id: '3',
        title: 'Coffee at Cafe',
        amount: 25000,
        category: 'Food',
        date: DateTime(2024, 9, 14),
        description: 'Morning coffee with friends',
      ),
      Expense(
        id: '4',
        title: 'Internet Bill',
        amount: 300000,
        category: 'Utilities',
        date: DateTime(2024, 9, 13),
        description: 'Monthly internet subscription',
      ),
      Expense(
        id: '5',
        title: 'Movie Ticket',
        amount: 100000,
        category: 'Entertainment',
        date: DateTime(2024, 9, 12),
        description: 'Weekend movie with family',
      ),
      Expense(
        id: '6',
        title: 'Buy Book',
        amount: 75000,
        category: 'Education',
        date: DateTime(2024, 9, 11),
        description: 'Programming book for learning',
      ),
      Expense(
        id: '7',
        title: 'Lunch',
        amount: 35000,
        category: 'Food',
        date: DateTime(2024, 9, 11),
        description: 'Lunch at a restaurant',
      ),
      Expense(
        id: '8',
        title: 'Bus Fare',
        amount: 10000,
        category: 'Transportation',
        date: DateTime(2024, 9, 10),
        description: 'Daily bus fare to campus',
      ),
  ];

  void _addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
  }

  void _editExpense(int index, Expense updatedExpense) {
  setState(() {
    ExpenseManager.updateExpense(index, updatedExpense);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense List'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Header total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total Expenses',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _calculateTotal(expenses),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // ListView
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(expense.category),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        expense.formattedDate,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    expense.formattedAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red[600],
                    ),
                  ),
                  onTap: () => _showExpenseDetails(context, index)
                ),
              );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddExpenseScreen(onAdd: _addExpense),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transportation':
        return Colors.green;
      case 'utilities':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'education':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'utilities':
        return Icons.home;
      case 'entertainment':
        return Icons.movie;
      case 'education':
        return Icons.school;
      default:
        return Icons.attach_money;
    }
  }

void _showExpenseDetails(BuildContext context, int index) {
  final expense = expenses[index];
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(expense.title),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // tutup dialog
            showDialog(
              context: context,
              builder: (_) => EditExpenseScreen(
                expense: expense,
                onEdit: (updated) {
                  setState(() {
                    expenses[index] = updated; 
                    _editExpense(index, updated);
                  });
                },
              ),
            );
          },
          child: const Text("Edit"),
        ),
      ],
    ),
  );
}
}
