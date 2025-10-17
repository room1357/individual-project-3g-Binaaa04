import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';

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
        title: const Text('Add Category'),
        content: TextField(
          controller: categoryNameController,
          decoration: const InputDecoration(hintText: 'Category name'),
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
            appBar: AppBar(title: const Text('Categories')),
            body: cats.isEmpty
                ? const Center(child: Text('No categories available'))
                : ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final cat = cats[index];
                      return ListTile(
                        title: Text(cat.categoryName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider._deleteCategory(cat.categoryId),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: _showAddDialog,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
