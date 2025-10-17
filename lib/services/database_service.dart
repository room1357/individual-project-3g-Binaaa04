import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import tabel kamu
import 'package:pemrograman_mobile/models/expenseTable.dart';
import 'package:pemrograman_mobile/models/user.dart';
import 'package:pemrograman_mobile/models/category.dart';

part 'database_service.g.dart';

@DriftDatabase(tables: [Kategory, expenseTable, User])
class AppDb extends _$AppDb {
  // Singleton pattern
  static final AppDb _instance = AppDb._internal();
  factory AppDb() => _instance;

  AppDb._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  Future<int> insertUser(UserCompanion entry) => into(user).insert(entry);
  Future<Users?> getUserByUsername(String username) async {
  return (select(user)
        ..where((tbl) => tbl.username.equals(username)))
      .getSingleOrNull();
}
  Future<void> initializeDefaultCategories() async {
    final data = await select(kategory).get();
    if (data.isEmpty) {
      final defaultCategories = [
        'Food',
        'Transportation',
        'Utility',
        'Entertainment',
        'Self Care'
      ];
      final now = DateTime.now();
      for (var name in defaultCategories) {
        await into(kategory).insert(
          KategoryCompanion.insert(
            categoryName: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
  }

}

// Fungsi koneksi database Drift
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
