import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.icon,
    this.isPassword = false,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF9CA3AF),
                size: 16,
              ),
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}