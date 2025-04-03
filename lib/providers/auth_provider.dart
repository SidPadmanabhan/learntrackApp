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

  // Helper methods to access user data fields
  String? get userFullName => _userData?['fullName'] as String?;
  String? get userEmail => _userData?['email'] as String? ?? _user?.email;
  int? get userAge => _userData?['age'] as int?;
  Timestamp? get userCreatedAt => _userData?['createdAt'] as Timestamp?;

  // Method to get user data as a formatted string (for debugging/display)
  String get userDataAsString {
    if (_userData == null) return 'No user data available';

    return 'Name: $userFullName\n'
        'Email: $userEmail\n'
        'Age: $userAge\n'
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
    _userData = null;
    notifyListeners();

    try {
      print('SIGNUP: Starting signup process');

      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('SIGNUP: Authentication successful, user created in Firebase Auth');

      final uid = userCredential?.user?.uid;
      print('SIGNUP: User UID: $uid');

      if (uid != null) {
        print('SIGNUP: Attempting to save user data to Firestore');
        try {
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

          // Store in local variable
          _userData = userData;

          print('SIGNUP: User data successfully saved to Firestore');
        } catch (firestoreError, firestoreStack) {
          print('SIGNUP: Firestore specific error: $firestoreError');
          print('SIGNUP: Firestore error stack: $firestoreStack');
          _error = 'Error saving profile data: $firestoreError';
          throw 'Failed to save user data to Firestore: $firestoreError';
        }
      } else {
        print('SIGNUP: User UID is null after authentication');
        _error = 'Authentication successful but user ID is missing';
      }
    } catch (e, stackTrace) {
      print('SIGNUP ERROR: $e');
      print('SIGNUP STACK: $stackTrace');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('SIGNUP: Process complete, isLoading set to false');
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    _userData = null;
    notifyListeners();

    try {
      print('SIGNIN: Starting signin process');

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('SIGNIN: Authentication successful');

      // Fetch user data from Firestore
      final uid = userCredential?.user?.uid;
      print('SIGNIN: User UID: $uid');

      if (uid != null) {
        print('SIGNIN: Fetching user data from Firestore');
        try {
          final docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (docSnapshot.exists && docSnapshot.data() != null) {
            _userData = docSnapshot.data();
            print('SIGNIN: User data fetched successfully');
            print('SIGNIN: User data: $_userData');
          } else {
            print('SIGNIN: No user data found in Firestore');
            _error = 'User profile data not found';
          }
        } catch (firestoreError) {
          print('SIGNIN: Error fetching user data: $firestoreError');
          // Don't set _error here as authentication was successful
        }
      }
    } catch (e) {
      print('SIGNIN ERROR: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('SIGNIN: Process complete, isLoading set to false');
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _userData = null;
      print('SIGNOUT: User signed out successfully');
    } catch (e) {
      print('SIGNOUT ERROR: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('SIGNOUT: Process complete');
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
