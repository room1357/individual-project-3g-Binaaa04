import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  final AppDb _db = AppDb();
  Users? _currentUser;
  Users? get currentUser => _currentUser;

  // Getter untuk cek apakah user sedang login
  bool get isAuth => _currentUser != null;

  // Fungsi register user
  Future<String> registerUser(String fullname, String email, String username, String password) async {
    final existingUser = await _db.getUserByUsername(username);
    final now = DateTime.now();

    if (existingUser != null) {
      return 'Username is already in use';
    }

    final user = UserCompanion.insert(
      fullname: fullname,
      email: email,
      username: username,
      password: password,
      createdAt: now,
      updatedAt: now,
    );

    await _db.insertUser(user);
    return 'Successful Registration';
  }

  // Fungsi login user
  Future<String> loginUser(String username, String password) async {
    final existingUser = await _db.getUserByUsername(username);

    if (existingUser == null) return 'Username not found';
    if (existingUser.password != password) return 'Incorrect password';

    _currentUser = existingUser;

    // Simpan userId di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', existingUser.userId);

    notifyListeners();
    return 'Success';
  }

  // Fungsi logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  // Fungsi untuk otomatis login saat app dibuka
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userId')) return;

    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final user = await _db.getUserById(userId);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }
}
