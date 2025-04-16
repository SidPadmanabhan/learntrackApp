import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String uid;
  final String email;
  final String? name;

  User({required this.uid, required this.email, this.name});
}

class AuthService {
  // Choose the appropriate base URL based on platform
  late final String baseUrl;

  AuthService() {
    if (kIsWeb) {
      // Web needs the full URL
      baseUrl = 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host's localhost
      baseUrl = 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // iOS simulator uses localhost
      baseUrl = 'http://localhost:8000/api';
    } else {
      // Default to localhost for other platforms
      baseUrl = 'http://localhost:8000/api';
    }

    print('Using base URL: $baseUrl');

    // Check server connectivity
    checkServerConnectivity();
  }

  User? _currentUser;

  // Get the current authenticated user
  User? get currentUser => _currentUser;

  // Stream to listen to auth state changes
  final ValueNotifier<User?> _authStateChanges = ValueNotifier<User?>(null);
  ValueNotifier<User?> get authStateChanges => _authStateChanges;

  // Initialize and check for stored token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        print('Calling token validation: $baseUrl/auth/validate');
        // Validate token with backend
        final response = await http.get(
          Uri.parse('$baseUrl/auth/validate'),
          headers: {'Authorization': 'Bearer $token'},
        );

        print('Validation response: ${response.statusCode} ${response.body}');

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          _currentUser = User(
            uid: userData['uid'],
            email: userData['email'],
            name: userData['name'],
          );
          _authStateChanges.value = _currentUser;
        } else {
          // Token invalid, clear it
          await prefs.remove('auth_token');
        }
      } catch (e) {
        print('Error during token validation: $e');
        // Error occurred, clear token
        await prefs.remove('auth_token');
      }
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    try {
      final url = '$baseUrl/auth/signup';
      print('Calling signup: $url');
      print('Request body: ${jsonEncode({
            'email': email,
            'password': password,
            'name': name,
            'age': age,
          })}');

      final response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'age': age,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Request timed out');
          throw 'Connection timed out. Please check if the server is running.';
        },
      );

      print('Signup response: ${response.statusCode} ${response.body}');

      // Check if response body is empty
      if (response.body.isEmpty) {
        throw 'Server returned empty response. Please check server logs.';
      }

      // Safely decode JSON
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('JSON parse error: $e for body: ${response.body}');
        throw 'Invalid response from server. Please check server logs.';
      }

      if (response.statusCode == 201) {
        final token = data['token'];

        if (token == null) {
          throw 'Server response missing token';
        }

        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        // Store user ID in SharedPreferences for path association
        final userId = data['uid'] ?? 'unknown';
        await prefs.setString('user_id', userId);

        // Set current user
        _currentUser = User(
          uid: userId,
          email: email,
          name: name,
        );
        _authStateChanges.value = _currentUser;

        return _currentUser;
      } else {
        throw data['message'] ?? 'An error occurred during sign up.';
      }
    } catch (e) {
      print('Error during signup: $e');
      throw e.toString();
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/auth/login';
      print('Calling login: $url');
      print('Request body: ${jsonEncode({
            'email': email,
            'password': password,
          })}');

      final response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Request timed out');
          throw 'Connection timed out. Please check if the server is running.';
        },
      );

      print('Login response: ${response.statusCode} ${response.body}');

      // Check if response body is empty
      if (response.body.isEmpty) {
        throw 'Server returned empty response. Please check server logs.';
      }

      // Safely decode JSON
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('JSON parse error: $e for body: ${response.body}');
        throw 'Invalid response from server. Please check server logs.';
      }

      if (response.statusCode == 200) {
        final token = data['token'];

        if (token == null) {
          throw 'Server response missing token';
        }

        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        // Store user ID in SharedPreferences for path association
        final userId = data['uid'] ?? 'unknown';
        await prefs.setString('user_id', userId);

        // Set current user
        _currentUser = User(
          uid: userId,
          email: email,
          name: data['name'],
        );
        _authStateChanges.value = _currentUser;

        return _currentUser;
      } else {
        throw data['message'] ?? 'An error occurred during sign in.';
      }
    } catch (e) {
      print('Error during login: $e');
      throw e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id'); // Remove user ID on sign out
      _currentUser = null;
      _authStateChanges.value = null;
    } catch (e) {
      throw 'An error occurred while signing out.';
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['message'] ??
            'An error occurred while sending password reset email.';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (_currentUser == null) return null;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/${_currentUser!.uid}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'An error occurred while getting user data.';
      }
    } catch (e) {
      throw 'Error getting user data: $e';
    }
  }

  // Check if the server is running
  Future<bool> checkServerConnectivity() async {
    try {
      // Use the healthcheck endpoint instead of root
      final serverUrl = baseUrl.replaceAll('/api', '/healthcheck');
      print('Checking server connectivity at: $serverUrl');

      final response = await http
          .get(
        Uri.parse(serverUrl),
        // Don't include Content-Type header for a GET request with no body
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Server connectivity check timed out');
          return http.Response('', 408); // 408 = Request Timeout
        },
      );

      print('Server response: ${response.statusCode} ${response.body}');

      try {
        // Try to parse as JSON
        final data = jsonDecode(response.body);
        return data != null &&
            response.statusCode == 200 &&
            data['status'] == 'ok';
      } catch (e) {
        print('Failed to parse healthcheck response: $e');
        return false;
      }
    } catch (e) {
      print('Error checking server connectivity: $e');
      return false;
    }
  }
}
