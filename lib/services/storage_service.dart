import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/expense.dart';

class StorageService {
  // Singleton pattern
  static final StorageService instance = StorageService._privateConstructor();
  StorageService._privateConstructor();

  // Simpan data ke SharedPreferences
  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseStrings =
        expenses.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('expenses', expenseStrings);
  }


  // Ambil data dari SharedPreferences
  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expenseStrings = prefs.getStringList('expenses');

    if (expenseStrings != null) {
      return expenseStrings
          .map((e) => Expense.fromJson(json.decode(e)))
          .toList();
    }
    return [];
  }

  // Export ke CSV — dengan izin & folder Download
  Future<void> exportExpensesToCSV(List<Expense> expenses, String filePath) async {
    // Minta izin penyimpanan
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print('❌ Storage permission denied');
      return;
    }

    // Buat data CSV
    List<List<String>> rows = [
      ['Title', 'Category', 'Amount', 'Date', 'Description'], // Header
      ...expenses.map((e) => [
            e.title,
            e.category,
            e.amount.toString(),
            e.formattedDate,
            e.description,
          ])
    ];

    String csvData = const ListToCsvConverter().convert(rows);

    //Simpan ke folder Download (Android)
    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      // Untuk iOS atau desktop, simpan ke documents directory
      directory = await getApplicationDocumentsDirectory();
    }

    final String path = '${directory.path}/expenses.csv';
    final File file = File(path);

    await file.writeAsString(csvData);

    print('✅ CSV file saved at: $path');
  }
}
