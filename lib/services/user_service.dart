import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _users => _firestore.collection('users');

  // Create new user document in Firestore
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String name,
    required int age,
    DateTime? createdAt,
  }) async {
    try {
      await _users.doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'age': age,
        'createdAt': createdAt ?? DateTime.now(),
        'lastLogin': DateTime.now(),
        'courses': [],
        'progress': {},
        'settings': {
          'notifications': true,
          'emailUpdates': true,
        }
      });
    } catch (e) {
      throw 'Error creating user document: $e';
    }
  }

  // Update user's last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _users.doc(uid).update({
        'lastLogin': DateTime.now(),
      });
    } catch (e) {
      throw 'Error updating last login: $e';
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _users.doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw 'Error getting user data: $e';
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String uid) async {
    try {
      DocumentSnapshot doc = await _users.doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw 'Error checking user existence: $e';
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
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (settings != null) updateData['settings'] = settings;

      await _users.doc(uid).update(updateData);
    } catch (e) {
      throw 'Error updating user profile: $e';
    }
  }
} 