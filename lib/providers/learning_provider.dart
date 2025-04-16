import 'package:flutter/material.dart';
import '../services/learning_service.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningProvider extends ChangeNotifier {
  final LearningService _learningService = LearningService();
  List<Map<String, dynamic>> _currentCourses = [];
  List<Map<String, dynamic>> _learningPaths = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _streakData;
  AuthProvider? _authProvider;

  LearningProvider() {
    _initialize();
  }

  // Set auth provider reference to listen for auth changes
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    // Listen for auth changes
    _authProvider!.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    // When auth state changes (login/logout), refresh learning data
    if (_authProvider!.isAuthenticated) {
      print('Auth state changed: User logged in. Refreshing learning data.');
      _initialize();
    } else {
      print('Auth state changed: User logged out. Clearing learning data.');
      // Clear data when user logs out
      _currentCourses = [];
      _learningPaths = [];
      _streakData = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_authProvider != null) {
      _authProvider!.removeListener(_onAuthStateChanged);
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      // First check if there's a logged-in user
      final uid = await _getUserId();
      if (uid != null) {
        // If user is already logged in, fetch their data
        await _fetchUserLearningData();
        await _fetchStreakData();
      } else {
        // No logged-in user, so use empty data
        _currentCourses = [];
        _learningPaths = [];
        _streakData = null;
      }
    } catch (e) {
      _error = e.toString();
      print('Error during LearningProvider initialization: $e');
    }
    notifyListeners();
  }

  // Clear all cached data, useful when switching users
  void clearData() {
    _currentCourses = [];
    _learningPaths = [];
    _streakData = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> get currentCourses => _currentCourses;
  List<Map<String, dynamic>> get learningPaths => _learningPaths;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get streakData => _streakData;

  Future<void> _fetchUserLearningData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Fetch current courses
      final courses = await _learningService.getCurrentCourses();
      _currentCourses = courses;

      // Fetch learning paths
      final paths = await _learningService.getLearningPaths();
      _learningPaths = paths;

      _isLoading = false;
      _error = null; // Clear any previous errors
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchStreakData() async {
    try {
      final streakData = await _learningService.getStreakData();
      _streakData = streakData;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> generateLearningPath(String topic) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPath = await _learningService.generatePathForTopic(topic);
      _learningPaths.add(newPath);

      // Add the topic to currently learning
      if (newPath['modules'] != null && newPath['modules'].isNotEmpty) {
        final firstModule = newPath['modules'][0];
        final newCourse = {
          'title': newPath['title'],
          'details':
              '${newPath['modules'].length} modules • ${newPath['estimatedHours']} hours',
          'progress': 0.0,
        };
        _currentCourses.add(newCourse);

        // Save the updated courses list to ensure persistence
        await _saveCourses();
      }

      _isLoading = false;
      notifyListeners();
      return newPath;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveCourses() async {
    try {
      final uid = await _getUserId();
      if (uid != null && _currentCourses.isNotEmpty) {
        await _learningService.saveCurrentCourses(_currentCourses);
      }
    } catch (e) {
      print('Error saving courses: $e');
    }
  }

  Future<String?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  Future<void> updateStreak(bool completed) async {
    try {
      // Update streak on server/local storage
      final result = await _learningService.updateDailyStreak(completed);

      // Regardless of server result, fetch fresh streak data to ensure UI is up-to-date
      await _fetchStreakData();

      // The streak data is now updated from the server or local storage
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
