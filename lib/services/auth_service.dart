// services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  // Static login method
  static Future<bool> login(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      
      // Cari user berdasarkan username dan password
      for (var userData in usersList) {
        final user = User.fromMap(userData);
        if (user.username == username && user.validatePassword(password)) {
          // Simpan current user
          await prefs.setString(_currentUserKey, user.toJson());
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Static logout method
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Instance method untuk register
  Future<bool> register(String username, String password, String email, String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      List<dynamic> usersList = json.decode(usersJson);
      
      // Cek apakah username atau email sudah digunakan
      for (var userData in usersList) {
        final existingUser = User.fromMap(userData);
        if (existingUser.username.toLowerCase() == username.toLowerCase()) {
          print('Username already exists: $username');
          return false;
        }
        if (existingUser.email.toLowerCase() == email.toLowerCase()) {
          print('Email already exists: $email');
          return false;
        }
      }
      
      // Buat user baru
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        phone: phone,
        password: password,
        createdAt: DateTime.now(),
      );
      
      // Tambahkan ke list
      usersList.add(newUser.toMap());
      
      // Simpan ke SharedPreferences
      await prefs.setString(_usersKey, json.encode(usersList));
      
      print('User registered successfully: $username');
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Instance method untuk cek login status
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  // Instance method untuk get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      if (userJson != null) {
        return json.decode(userJson);
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
}