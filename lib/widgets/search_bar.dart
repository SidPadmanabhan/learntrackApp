import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFFADAEBC),
              ),
              decoration: InputDecoration(
                hintText: 'What would you like to learn?',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFFADAEBC),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}