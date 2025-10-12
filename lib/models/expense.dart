import 'package:drift/drift.dart';
@DataClassName('Expense')

class expenseTable extends Table{
  IntColumn get expenseId => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: 128)();
  IntColumn get categoryId => integer()();
  IntColumn get amount => integer()();
  DateTimeColumn get date =>dateTime()();
  TextColumn get description => text().withLength(max: 128)();
  DateTimeColumn get createdAt =>dateTime()();
  DateTimeColumn get updatedAt =>dateTime()();
  DateTimeColumn get deletedAt =>dateTime().nullable()();
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  // Getter untuk format tampilan mata uang
  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
  
  // Getter untuk format tampilan tanggal
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Fungsi untuk mengonversi objek ke Map untuk JSON (dapat dipakai untuk SharedPreferences atau lainnya)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  // Fungsi untuk membuat objek Expense dari Map (dari JSON)
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  // Fungsi toJson untuk serialisasi objek Expense menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    return toMap();  
  }
}
