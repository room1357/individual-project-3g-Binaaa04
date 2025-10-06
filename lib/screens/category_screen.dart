import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
   final List<String> existingCategories;
  const CategoryScreen({super.key,required this.existingCategories});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late List<String> categories;
    final TextEditingController _controller = TextEditingController();
  // List buat simpan kategori
   @override
  void initState() {
    super.initState();
    categories = List.from(widget.existingCategories);
  }

  // Tambah kategori
  void _addCategory(String name) {
    final newCategory = _controller.text.trim();
    if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
      setState(() {
        categories.add(newCategory);
        _controller.clear();
      });
    }
  }

  // Tampilkan dialog untuk input kategori baru
  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Category'),
        content: TextField(
          onChanged: (value) => newCategory = value,
          decoration: InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // tutup dialog
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newCategory.trim().isNotEmpty) {
                _addCategory(newCategory.trim());
              }
              Navigator.pop(context,categories);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Hapus kategori
  void _deleteCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Category")),
      body: categories.isEmpty
          ? Center(child: Text("Belum ada kategori"))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(categories[index]),
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
