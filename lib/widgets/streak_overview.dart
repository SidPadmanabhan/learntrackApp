import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/learning_provider.dart';
import 'streak_day.dart';

class StreakOverview extends StatefulWidget {
  const StreakOverview({Key? key}) : super(key: key);

  @override
  State<StreakOverview> createState() => _StreakOverviewState();
}

class _StreakOverviewState extends State<StreakOverview> {
  bool _isLoading = false;
  bool _justCompleted = false;
  // Local copy of streak data for immediate UI updates
  Map<String, dynamic>? _localStreakData;
  int _lastStreakDataHash = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if provider data has changed and reset local data if needed
    final provider = Provider.of<LearningProvider>(context, listen: false);
    final streakData = provider.streakData;

    if (streakData != null) {
      final newHash = _computeStreakDataHash(streakData);
      if (_lastStreakDataHash != newHash) {
        setState(() {
          _localStreakData = null;
          _lastStreakDataHash = newHash;
        });
      }
    } else if (_localStreakData != null) {
      // If provider data is null but we have local data, reset it
      setState(() {
        _localStreakData = null;
        _lastStreakDataHash = 0;
      });
    }
  }

  // Compute a simple hash of the streak data to detect changes
  int _computeStreakDataHash(Map<String, dynamic> data) {
    int hash = 0;
    // Add current streak to hash
    hash += (data['currentStreak'] as int? ?? 0) * 1000;

    // Add day completion status to hash
    final days = data['days'] as List<dynamic>? ?? [];
    for (int i = 0; i < days.length; i++) {
      if (days[i]['completed'] as bool? ?? false) {
        hash += (i + 1) * 10;
      }
    }

    return hash;
  }

  Future<void> _completeToday() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final learningProvider =
          Provider.of<LearningProvider>(context, listen: false);

      // Get the current data
      final streakData = learningProvider.streakData;
      if (streakData != null) {
        // Make a deep copy of streak data
        _localStreakData = Map<String, dynamic>.from(streakData);

        // Update the local copy for immediate UI update
        final now = DateTime.now();
        final weekday = now.weekday;
        final todayIndex = weekday > 5 ? 4 : weekday - 1;

        if (_localStreakData!['days'] != null &&
            todayIndex >= 0 &&
            todayIndex < (_localStreakData!['days'] as List).length) {
          // Update today's day to completed
          (_localStreakData!['days'] as List)[todayIndex]['completed'] = true;

          // Update current streak count
          _localStreakData!['currentStreak'] =
              (_localStreakData!['currentStreak'] as int? ?? 0) + 1;

          // Update week progress
          final completedDays = (_localStreakData!['days'] as List)
              .where((day) => day['completed'] == true)
              .length;
          _localStreakData!['weekProgress'] =
              completedDays / (_localStreakData!['days'] as List).length;
        }
      }

      // Now update the real data in the provider
      await learningProvider.updateStreak(true);

      // Mark as just completed to show a success message briefly
      setState(() {
        _justCompleted = true;
        _isLoading = false;
      });

      // Reset the success message after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _justCompleted = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, _) {
        // Use local data if available (for immediate UI update) or fall back to provider data
        final streakData = _localStreakData ?? learningProvider.streakData;
        final int currentStreak = streakData?['currentStreak'] as int? ?? 0;
        final double weekProgress =
            streakData?['weekProgress'] as double? ?? 0.0;
        final List<dynamic> days = streakData?['days'] as List<dynamic>? ?? [];

        final isTodayDone = _isTodayCompleted(days);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Streak Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$currentStreak days',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map<Widget>((day) {
                  return StreakDay(
                    day: day['day'] as String? ?? '',
                    isCompleted: day['completed'] as bool? ?? false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  height: 8,
                  color: const Color(0xFFE5E7EB),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.8 *
                            weekProgress,
                        color: const Color(0xFF4F46E5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Show success message if just completed
              if (_justCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Day completed! 🎉',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF14532D),
                        ),
                      ),
                    ],
                  ),
                )
              // Add button to mark today as completed if not already done
              else if (!isTodayDone)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeToday,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Complete Today',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )
              // Show completed status if already done
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Today completed',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isTodayCompleted(List<dynamic> days) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 for Monday, 7 for Sunday

    // If it's weekend, consider Friday as "today" for the UI
    final todayIndex = weekday > 5 ? 4 : weekday - 1;

    if (todayIndex >= 0 && todayIndex < days.length) {
      return days[todayIndex]['completed'] as bool? ?? false;
    }
    return false;
  }
}
