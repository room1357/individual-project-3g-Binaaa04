import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/services/database_service.dart';
import 'package:pemrograman_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  final AppDb _db = AppDb();
  final ApiService _api = ApiService();
  Users? _currentUser;
  Users? get currentUser => _currentUser;

  // Getter untuk cek apakah user sedang login
  bool get isAuth => _currentUser != null;

  // Fungsi register user
  Future<String> registerUser(String fullname, String email, String username, String password) async {
    try {
      // Cek apakah username sudah ada via API
      final existing = await _api.getUserByUsername(username);
      if (existing != null) {
        return 'Username is already in use';
      }

      // Create user via API
      final result = await _api.createUser(
        fullname: fullname,
        email: email,
        username: username,
        password: password,
      );

      if (result == null) {
        return 'Registration Failed';
      }

      return 'Successful Registration';
    } catch (e) {
      print('❌ Registration error: $e');
      return 'Registration Failed';
    }
  }

  // Fungsi login user
  Future<String> loginUser(String username, String password) async {
    try {
      final userData = await _api.getUserByUsername(username);

      if (userData == null) return 'Username not found';

      // Convert API response to Users object
      _currentUser = Users(
        userId: userData['userId'],
        fullname: userData['fullname'],
        email: userData['email'],
        username: userData['username'],
        password: userData['password'],
        createdAt: DateTime.parse(userData['createdAt']),
        updatedAt: DateTime.parse(userData['updatedAt']),
      );

      if (_currentUser!.password != password) return 'Incorrect password';

      // Simpan userId di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _currentUser!.userId);

      notifyListeners();
      return 'Success';
    } catch (e) {
      print('❌ Login error: $e');
      return 'Login Failed';
    }
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

    final userData = await _api.getUserById(userId);
    if (userData == null) return;

    _currentUser = Users(
      userId: userData['userId'],
      fullname: userData['fullname'],
      email: userData['email'],
      username: userData['username'],
      password: userData['password'],
      createdAt: DateTime.parse(userData['createdAt']),
      updatedAt: DateTime.parse(userData['updatedAt']),
    );

    notifyListeners();
  }
}
