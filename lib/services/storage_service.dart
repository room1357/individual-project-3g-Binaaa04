import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class StorageService {
  static final StorageService instance = StorageService._privateConstructor();

  StorageService._privateConstructor();

  // Simpan daftar expenses ke storage (bisa SharedPreferences atau database)
  Future<void> saveExpenses(List<Expense> expenses) async {
    // Misal pake SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseStrings = expenses.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('expenses', expenseStrings);
  }

  // Ambil daftar expenses dari storage
  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expenseStrings = prefs.getStringList('expenses');
    if (expenseStrings != null) {
      return expenseStrings.map((e) => Expense.fromJson(json.decode(e))).toList();
    }
    return [];
  }


  // static final StorageService instance = StorageService._init();

  // static Database? _database;

  // StorageService._init();

  // Future<Database> get database async {
  //   if (_database != null) return _database!;
  //   _database = await _initDB('expenses.db');
  //   return _database!;
  // }

  // Future<Database> _initDB(String filePath) async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, filePath);
  //   return await openDatabase(path, version: 1, onCreate: _createDB);
  // }

  // Future _createDB(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE expenses (
  //       id TEXT PRIMARY KEY,
  //       title TEXT NOT NULL,
  //       amount REAL NOT NULL,
  //       category TEXT NOT NULL,
  //       date TEXT NOT NULL,
  //       description TEXT
  //     )
  //   ''');
  // }

  // Future<void> insertExpense(Expense expense) async {
  //   final db = await instance.database;
  //   await db.insert(
  //     'expenses',
  //     expense.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  //   print("Expense inserted: ${expense.title}");
  // }

  // Future<List<Expense>> getExpenses() async {
  //   final db = await instance.database;
  //   final result = await db.query('expenses', orderBy: 'date DESC');
  //   return result.map((json) => Expense.fromMap(json)).toList();
  // }

  // Future close() async {
  //   final db = await instance.database;
  //   db.close();
  // }
}

