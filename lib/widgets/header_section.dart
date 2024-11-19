import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F5AFF), Color(0xFF00D8A5)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_circle_rounded),
            ),
            const SizedBox(width: 12),
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_rounded),
        ),
      ],
    );
  }
} 