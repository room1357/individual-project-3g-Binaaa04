import 'package:drift/drift.dart';

@DataClassName('Users')
class User extends Table {
  IntColumn get userId => integer().autoIncrement()();
  TextColumn get fullname => text().withLength(max: 128)();
  TextColumn get email => text().withLength(max: 128)();
  TextColumn get username => text().withLength(max: 128)();
  TextColumn get password => text().withLength(max: 128)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class UsersData {
  final int? userId;
  final String fullname;
  final String email;
  final String username;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  UsersData({
    this.userId,  // userId bisa null karena autoIncrement
    required this.fullname,
    required this.email,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  // Fungsi untuk mengonversi objek ke Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,  // Bisa null karena autoIncrement
      'fullname': fullname,
      'email': email,
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Fungsi untuk membuat objek UsersData dari Map (biasanya dari database)
  factory UsersData.fromMap(Map<String, dynamic> map) {
    return UsersData(
      userId: map['userId'],  // userId bisa null
      fullname: map['fullname'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Fungsi untuk mengonversi objek ke JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // Fungsi untuk membuat objek UsersData dari JSON
  factory UsersData.fromJson(Map<String, dynamic> json) {
    return UsersData.fromMap(json);
  }
}
