import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'streak_day.dart';

class StreakOverview extends StatelessWidget {
  const StreakOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              Text(
                '7 days',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StreakDay(day: 'Mon', isCompleted: true),
              StreakDay(day: 'Tue', isCompleted: true),
              StreakDay(day: 'Wed', isCompleted: true),
              StreakDay(day: 'Thu', isCompleted: true),
              StreakDay(day: 'Fri', isCompleted: false),
            ],
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
                    width: MediaQuery.of(context).size.width * 0.8,
                    color: const Color(0xFF4F46E5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}