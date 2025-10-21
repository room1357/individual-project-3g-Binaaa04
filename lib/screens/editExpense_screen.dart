import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/expense_manager.dart';
import '../utils/app_theme.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseWithCategory expense;
  final List<Kategori> categories;
  final Function(ExpenseWithCategory) onEdit;

  const EditExpenseScreen({
    Key? key,
    required this.expense,
    required this.categories,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  int? selectedCategoryIndex;
  late DateTime selectedDate;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.expense.title);
    amountController = TextEditingController(text: widget.expense.amount.toString());
    descriptionController = TextEditingController(text: widget.expense.description);
    selectedDate = widget.expense.date;
    selectedCategoryIndex = widget.categories.indexWhere((c) => c.categoryName == widget.expense.categoryName);
    if (selectedCategoryIndex == -1) selectedCategoryIndex = 0;
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _save() async {
    if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final updated = ExpenseWithCategory(
        expenseId: widget.expense.expenseId,
        title: titleController.text.trim(),
        amount: int.tryParse(amountController.text.trim()) ?? widget.expense.amount,
        date: selectedDate,
        description: descriptionController.text.trim(),
        categoryName: widget.categories[selectedCategoryIndex!].categoryName,
      );
      
      widget.onEdit(updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating expense: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Edit Expense',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            prefixIcon: Icon(Icons.title_rounded),
            hintText: 'Enter expense title',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixIcon: Icon(Icons.attach_money_rounded),
            hintText: 'Enter amount',
            prefixText: 'Rp ',
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: selectedCategoryIndex,
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category_rounded),
          ),
          items: widget.categories.asMap().entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value.categoryName),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedCategoryIndex = value),
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
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Icons.description_rounded),
            hintText: 'Enter description (optional)',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }
}
