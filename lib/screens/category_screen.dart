import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final List<String> existingCategories;

  const CategoryScreen({Key? key, required this.existingCategories}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late List<String> categories;

  @override
  void initState() {
    super.initState();
    categories = List.from(widget.existingCategories);

    // 🔥 Langsung tampilkan form tambah kategori setelah layar terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddCategoryDialog();
    });
  }

  // Menampilkan dialog tambah kategori
  void _showAddCategoryDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Category'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCategory = _controller.text.trim();
              if (newCategory.isNotEmpty) {
                setState(() {
                  categories.add(newCategory);
                });
                Navigator.pop(context); // Tutup dialog
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: categories.isEmpty
          ? Center(child: Text('No categories available.'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(categories[index]),
                onTap: () => Navigator.pop(context, categories[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteCategory(index),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
