import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with ChangeNotifier {
  final AppDb database = AppDb();
  final categoryNameController = TextEditingController();

  List<Kategori> _categories = [];
  List<Kategori> get categories => _categories;

  final List<String> defaultCategories = [
    'Food',
    'Transportation',
    'Utility',
    'Entertainment',
    'Self Care'
  ];

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    final data = await database.select(database.kategory).get();

    if (data.isEmpty) {
      DateTime now = DateTime.now();
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

    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await database.select(database.kategory).get();
    _categories = data;
    notifyListeners(); // ini penting supaya UI yang pakai Consumer update
  }

  Future<void> _addCategory(String name) async {
    DateTime now = DateTime.now();
    await database.into(database.kategory).insert(
      KategoryCompanion.insert(
        categoryName: name,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _loadCategories();
  }

  Future<void> _deleteCategory(int id) async {
    await (database.delete(database.kategory)..where((t) => t.categoryId.equals(id))).go();
    await _loadCategories();
  }

  void _showAddDialog() {
    categoryNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_circle_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add Category'),
          ],
        ),
        content: TextField(
          controller: categoryNameController,
          decoration: const InputDecoration(
            hintText: 'Enter category name',
            prefixIcon: Icon(Icons.category_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = categoryNameController.text.trim();
              if (name.isNotEmpty) {
                await _addCategory(name);
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_CategoryScreenState>.value(
      value: this,
      child: Consumer<_CategoryScreenState>(
        builder: (context, provider, _) {
          final cats = provider.categories;
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            appBar: AppBar(
              title: const Text('Categories'),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: cats.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildCategoriesList(cats),
                      ],
                    ),
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _showAddDialog,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Category'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first category to organize expenses',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.category_rounded,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Organize your expenses by category',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<Kategori> categories) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: categories.map((category) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                category.categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Created: ${_formatDate(category.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  onPressed: () => _showDeleteDialog(category),
                  tooltip: 'Delete Category',
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteDialog(Kategori category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Category'),
          ],
        ),
        content: Text('Are you sure you want to delete "${category.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteCategory(category.categoryId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
