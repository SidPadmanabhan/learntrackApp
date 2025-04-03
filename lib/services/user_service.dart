import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = 'http://localhost:5000/api'; // Change to your Flask API URL

  // Get auth token from shared preferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Create new user document
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String name,
    required int age,
    DateTime? createdAt,
  }) async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'uid': uid,
          'email': email,
          'name': name,
          'age': age,
          'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Error creating user document';
      }
    } catch (e) {
      throw 'Error creating user document: $e';
    }
  }

  // Update user's last login
  Future<void> updateLastLogin(String uid) async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$uid/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Error updating last login';
      }
    } catch (e) {
      throw 'Error updating last login: $e';
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/$uid'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Error getting user data';
      }
    } catch (e) {
      throw 'Error getting user data: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    int? age,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final token = await _getAuthToken();
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (settings != null) updateData['settings'] = settings;

      final response = await http.patch(
        Uri.parse('$baseUrl/users/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );
      
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Error updating user profile';
      }
    } catch (e) {
      throw 'Error updating user profile: $e';
    }
  }
} 