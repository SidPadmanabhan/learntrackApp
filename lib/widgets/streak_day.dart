import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakDay extends StatelessWidget {
  final String day;
  final bool isCompleted;

  const StreakDay({
    Key? key,
    required this.day,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
            color:
                isCompleted ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: isCompleted ? const Color(0xFFEEF2FF) : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFD1D5DB),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 18,
                    color: Color(0xFF4F46E5),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
