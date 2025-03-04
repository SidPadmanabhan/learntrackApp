import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakDay extends StatelessWidget {
  final String day;
  final bool isCompleted;

  const StreakDay({
    Key? key,
    required this.day,
    required this.isCompleted,
  }) : super(key: key);

  String get _statusIcon {
    return isCompleted
        ? '''<svg width="14" height="16" viewBox="0 0 14 16" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M13.7063 3.29395C14.0969 3.68457 14.0969 4.31895 13.7063 4.70957L5.70627 12.7096C5.31565 13.1002 4.68127 13.1002 4.29065 12.7096L0.290649 8.70957C-0.0999756 8.31895 -0.0999756 7.68457 0.290649 7.29395C0.681274 6.90332 1.31565 6.90332 1.70627 7.29395L5.00002 10.5846L12.2938 3.29395C12.6844 2.90332 13.3188 2.90332 13.7094 3.29395H13.7063Z" fill="#10B981"/>
           </svg>'''
        : '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M8 16C10.1217 16 12.1566 15.1571 13.6569 13.6569C15.1571 12.1566 16 10.1217 16 8C16 5.87827 15.1571 3.84344 13.6569 2.34315C12.1566 0.842855 10.1217 0 8 0C5.87827 0 3.84344 0.842855 2.34315 2.34315C0.842855 3.84344 0 5.87827 0 8C0 10.1217 0.842855 12.1566 2.34315 13.6569C3.84344 15.1571 5.87827 16 8 16Z" fill="#D1D5DB"/>
           </svg>''';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Center(
            child: SvgPicture.string(
              _statusIcon,
              width: 14,
              height: 16,
            ),
          ),
        ),
      ],
    );
  }
}