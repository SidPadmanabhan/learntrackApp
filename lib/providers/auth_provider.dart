import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this is at the top

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user == null) {
        _userData = null;
      } else {
        // When auth state changes to logged in, fetch user data
        fetchUserData(user.uid).then((data) {
          _userData = data;
          notifyListeners();
        }).catchError((e) {
          print('Error fetching user data on auth state change: $e');
        });
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Helper methods to access common user data
  String? get fullName => _userData?['fullName'] as String?;
  int? get age => _userData?['age'] as int?;
  String? get email => _user?.email;

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
          final userDataMap = {
            'fullName': fullName,
            'email': email,
            'age': age,
            'createdAt': Timestamp.now(),
          };

          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(userDataMap);

          // Store locally in provider
          _userData = userDataMap;

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
    notifyListeners();

    try {
      print('SIGNIN: Attempting to sign in with email');
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('SIGNIN: Authentication successful');

      // Fetch user data from Firestore if authentication is successful
      final uid = userCredential?.user?.uid;
      if (uid != null) {
        try {
          final userData = await fetchUserData(uid);
          if (userData != null) {
            _userData = userData; // Store the user data
            print('SIGNIN: User profile loaded: ${userData['fullName']}');
          }
        } catch (profileError) {
          // Just log profile errors but don't prevent sign-in
          print('SIGNIN: Error loading user profile: $profileError');
        }
      }
    } catch (e) {
      print('SIGNIN ERROR: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('SIGNIN: Process complete');
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
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

  // Add a method to fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    try {
      print('SIGNIN: Fetching user data from Firestore for user $uid');
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        print('SIGNIN: User data found in Firestore');
        return docSnapshot.data();
      } else {
        print('SIGNIN: No user data found in Firestore');
        return null;
      }
    } catch (e) {
      print('SIGNIN: Error fetching user data: $e');
      throw 'Failed to fetch user data: $e';
    }
  }
}
