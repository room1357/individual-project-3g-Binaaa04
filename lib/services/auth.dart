import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/services/database_service.dart';

class Auth with ChangeNotifier {
  final AppDb _db = AppDb();
  Users? _currentUser;
  Users? get currentUser => _currentUser;
  // Fungsi register user
  Future<String> registerUser(String fullname, String email, String username, String password) async {
    // Cek apakah username sudah ada
    final existingUser = await _db.getUserByUsername(username);
    final now = DateTime.now();

    if (existingUser != null) {
      return 'Username is already in use';
    }
    final User = UserCompanion.insert(fullname: fullname, email: email, username: username, password: password, createdAt: now, updatedAt: now);
    await _db.insertUser(User);
    return 'Successful Registration';

}
  Future<String> loginUser(String username, String password) async {
    // Cari user berdasarkan username
    final existingUser = await _db.getUserByUsername(username);

    if (existingUser == null) {
      return 'Username not found';
    }

    if (existingUser.password != password) {
      return 'Incorrect password';
    }

    _currentUser = existingUser;
    notifyListeners(); 
    return 'Success';
  }
}
