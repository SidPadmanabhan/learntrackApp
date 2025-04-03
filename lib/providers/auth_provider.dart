import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this is at the top

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get userData => _userData;

  // Helper methods to access user data
  String? get fullName => _userData?['fullName'] as String?;
  String? get email => _userData?['email'] as String? ?? _user?.email;
  int? get age => _userData?['age'] as int?;
  Timestamp? get userCreatedAt => _userData?['createdAt'] as Timestamp?;

  // Method to get user data as a formatted string (for debugging/display)
  String get userDataAsString {
    if (_userData == null) return 'No user data available';

    return 'Name: $fullName\n'
        'Email: $email\n'
        'Age: $age\n'
        'Account created: ${userCreatedAt?.toDate().toString() ?? 'unknown'}';
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required int age,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential?.user?.uid;
      if (uid != null) {
        // Create user data map
        final userData = {
          'fullName': fullName,
          'email': email,
          'age': age,
          'createdAt': Timestamp.now(),
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(userData);

        // Store locally
        _userData = userData;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final uid = userCredential?.user?.uid;
      if (uid != null) {
        try {
          final docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (docSnapshot.exists && docSnapshot.data() != null) {
            _userData = docSnapshot.data();
          }
        } catch (e) {
          print('Error fetching user data: $e');
          // Don't set _error here as authentication was successful
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _userData = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
