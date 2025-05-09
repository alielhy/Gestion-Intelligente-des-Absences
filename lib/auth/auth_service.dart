import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  // Save token and user data
  static Future<void> saveAuthData(String token, Map<String, dynamic> user) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  // Get stored token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUser() async {
    final userString = await _storage.read(key: _userKey);
    return userString != null ? jsonDecode(userString) : null;
  }

  // Clear auth data (logout)
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.100.66:5000/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'gmailAcademique': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }
}