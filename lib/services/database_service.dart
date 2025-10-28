import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import tabel kamu
import 'package:pemrograman_mobile/models/expenseTable.dart';
import 'package:pemrograman_mobile/models/user.dart';
import 'package:pemrograman_mobile/models/category.dart';
import 'package:pemrograman_mobile/services/api_service.dart';

part 'database_service.g.dart';

@DriftDatabase(tables: [Kategory, expenseTable, User])
class AppDb extends _$AppDb {
  // Singleton pattern
  static final AppDb _instance = AppDb._internal();
  factory AppDb() => _instance;

  final ApiService _api = ApiService();

  AppDb._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // =====================
  // USER FUNCTIONS
  // =====================

  // Insert user - KEEP for backward compatibility but should use API
  Future<int> insertUser(UserCompanion entry) => into(user).insert(entry);

  // Ambil user berdasarkan username - now using API
  Future<Users?> getUserByUsername(String username) async {
    final data = await _api.getUserByUsername(username);
    if (data == null) return null;
    
    return Users(
      userId: data['userId'],
      fullname: data['fullname'],
      email: data['email'],
      username: data['username'],
      password: data['password'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  // Ambil user berdasarkan userId - now using API
  Future<Users?> getUserById(int userId) async {
    final data = await _api.getUserById(userId);
    if (data == null) return null;
    
    return Users(
      userId: data['userId'],
      fullname: data['fullname'],
      email: data['email'],
      username: data['username'],
      password: data['password'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  // =====================
  // CATEGORY FUNCTIONS
  // =====================
  Future<void> initializeDefaultCategories() async {
    // Use API to check and create categories
    final categories = await _api.getCategories();
    if (categories.isEmpty) {
      final defaultCategories = [
        'Food',
        'Transportation',
        'Utility',
        'Entertainment',
        'Self Care'
      ];
      print('📦 Setting up default categories via API...');
      for (var name in defaultCategories) {
        await _api.createCategory(name);
      }
      print('✅ Default categories created');
    } else {
      print('✅ Categories already exist (${categories.length} categories)');
    }
  }
}

// =====================
// DATABASE CONNECTION
// =====================
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
