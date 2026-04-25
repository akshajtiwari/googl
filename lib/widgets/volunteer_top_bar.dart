import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VolunteersTopBar extends StatelessWidget {
  const VolunteersTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDADCE0), width: 1)),
      ),
      child: Row(
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'Volunteers  ',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202124), // Google dark grey
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'April 2026',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5F6368), // Google secondary text
                ),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.event_outlined, size: 20, color: Color(0xFF5F6368)),
          const Spacer(),

          // Google Style M3 Search Pill
          Container(
            width: 240,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4), // Google light grey input
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, size: 18, color: Color(0xFF5F6368)),
                SizedBox(width: 8),
                Text('Search volunteers...',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5F6368), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Google Icon Button
          IconButton(
            onPressed: () {},
            icon: const Badge(
              backgroundColor: Color(0xFFD93025), // Google Red
              smallSize: 8,
              child: Icon(Icons.notifications_none_rounded, color: Color(0xFF5F6368)),
            ),
            splashRadius: 24,
            hoverColor: const Color(0xFFF1F3F4),
          ),
          const SizedBox(width: 16),

          // User Profile Block
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kavya R.',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
              Text('Coordinator',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1A73E8), // Google Blue
            child: Text('KR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}