import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan URL API backend Anda
  // Contoh: 'http://localhost:3000/api' atau 'https://your-api.com/api'
  // GANTI URL INI dengan URL API backend Anda!
  // Untuk Android Emulator: http://10.0.2.2:3000/api
  // Untuk iOS Simulator: http://localhost:3000/api
  // Untuk Web: http://localhost:3000/api
  // Untuk Physical Device: http://<IP-KOMPUTER>:3000/api
  static const String baseUrl = 'http://192.168.5.14:3000/api';

  static ApiService? _instance;
  ApiService._internal();
  
  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  // Helper methods
  Future<Map<String, dynamic>?> _get(String endpoint) async {
    try {
      print('🚀 API Call: GET $baseUrl$endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('📡 Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Data: $data');
        return data;
      } else {
        print('❌ Error GET $endpoint: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception GET $endpoint: $e');
      return null;
    }
  }

  Future<List<dynamic>> _getList(String endpoint) async {
    try {
      print('🚀 API Call: GET $baseUrl$endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('📡 Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data is List ? data : [];
        print('✅ Data Count: ${list.length}');
        return list;
      } else {
        print('❌ Error GET $endpoint: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception GET $endpoint: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      print('🚀 API Call: POST $baseUrl$endpoint');
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(Duration(seconds: 10));
      
      print('📡 Response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Data: $data');
        return data;
      } else {
        print('❌ Error POST $endpoint: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception POST $endpoint: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _put(String endpoint, Map<String, dynamic> body) async {
    try {
      print('🚀 API Call: PUT $baseUrl$endpoint');
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(Duration(seconds: 10));
      
      print('📡 Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Data: $data');
        return data;
      } else {
        print('❌ Error PUT $endpoint: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception PUT $endpoint: $e');
      return null;
    }
  }

  Future<bool> _delete(String endpoint) async {
    try {
      print('🚀 API Call: DELETE $baseUrl$endpoint');
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('📡 Response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Exception DELETE $endpoint: $e');
      return false;
    }
  }

  // =====================
  // USER ENDPOINTS
  // =====================

  Future<Map<String, dynamic>?> createUser({
    required String fullname,
    required String email,
    required String username,
    required String password,
  }) async {
    return await _post('/users', {
      'fullname': fullname,
      'email': email,
      'username': username,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final response = await _get('/users/username/$username');
    return response;
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final response = await _get('/users/$userId');
    return response;
  }

  // =====================
  // CATEGORY ENDPOINTS
  // =====================

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _getList('/categories');
    return response.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> createCategory(String categoryName) async {
    return await _post('/categories', {
      'categoryName': categoryName,
    });
  }

  Future<Map<String, dynamic>?> updateCategory(int categoryId, String categoryName) async {
    return await _put('/categories/$categoryId', {
      'categoryName': categoryName,
    });
  }

  Future<bool> deleteCategory(int categoryId) async {
    return await _delete('/categories/$categoryId');
  }

  // =====================
  // EXPENSE ENDPOINTS
  // =====================

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final response = await _getList('/expenses');
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getExpensesByUserId(int userId) async {
    final response = await _getList('/expenses/user/$userId');
    return response.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getExpenseById(int expenseId) async {
    return await _get('/expenses/$expenseId');
  }

  Future<Map<String, dynamic>?> createExpense({
    required int userId,
    required String title,
    required int categoryId,
    required int amount,
    required DateTime date,
    required String description,
  }) async {
    return await _post('/expenses', {
      'userId': userId,
      'title': title,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    });
  }

  Future<Map<String, dynamic>?> updateExpense({
    required int expenseId,
    required int userId,
    required String title,
    required int categoryId,
    required int amount,
    required DateTime date,
    required String description,
  }) async {
    return await _put('/expenses/$expenseId', {
      'userId': userId,
      'title': title,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    });
  }

  Future<bool> deleteExpense(int expenseId) async {
    return await _delete('/expenses/$expenseId');
  }

  // Method untuk mengambil expenses dengan kategori (join)
  Future<List<Map<String, dynamic>>> getExpensesWithCategory() async {
    final expenses = await getExpenses();
    final categories = await getCategories();
    
    // Buat map untuk lookup kategori
    final categoryMap = {for (var c in categories) c['categoryId']: c};
    
    // Gabungkan expenses dengan categories
    return expenses.map((expense) {
      final categoryId = expense['categoryId'] as int;
      final category = categoryMap[categoryId];
      
      return {
        ...expense,
        'categoryName': category?['categoryName'] ?? 'Uncategorized',
      };
    }).toList();
  }

  // Get statistics for a user
  Future<Map<String, dynamic>?> getStatistics(int userId) async {
    final response = await _get('/statistics/$userId');
    return response;
  }

  // Get expenses with category for a specific user
  Future<List<Map<String, dynamic>>> getExpensesWithCategoryByUserId(int userId) async {
    final expenses = await getExpensesByUserId(userId);
    final categories = await getCategories();
    
    // Buat map untuk lookup kategori
    final categoryMap = {for (var c in categories) c['categoryId']: c};
    
    // Gabungkan expenses dengan categories
    return expenses.map((expense) {
      final categoryId = expense['categoryId'] as int;
      final category = categoryMap[categoryId];
      
      return {
        ...expense,
        'categoryName': category?['categoryName'] ?? 'Uncategorized',
      };
    }).toList();
  }
}

