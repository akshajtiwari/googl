import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../services/volunteer_mock_data.dart';
import '../../widgets/heatmap_preview.dart';

class VolunteerSummaryCard extends StatelessWidget {
  const VolunteerSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vol = VolunteerMockData.selectedVolunteer;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDADCE0), width: 1), // Google sharp border
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF1A73E8).withOpacity(0.1),
            child: const Text('RS',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1A73E8))),
          ),
          const SizedBox(width: 24),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(vol.name,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
                const SizedBox(height: 4),
                Text(vol.role,
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF5F6368)),
                    const SizedBox(width: 4),
                    Text(vol.zone, style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368))),
                  ],
                ),
              ],
            ),
          ),
          
          // Ring Charts
          _RingChart(
            value: vol.completionRate,
            color: const Color(0xFF1E8E3E), // Google Green
            label: 'Task completion',
            display: '${(vol.completionRate * 100).toInt()}%',
          ),
          const SizedBox(width: 48),
          _RingChart(
            value: vol.availability,
            color: const Color(0xFFF9AB00), // Google Yellow
            label: 'Availability',
            display: '${(vol.availability * 100).toInt()}%',
          ),
          const SizedBox(width: 48),
          
          // Map preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 180,
              height: 100,
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDADCE0))),
              child: const HeatmapPreview(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingChart extends StatelessWidget {
  final double value;
  final Color color;
  final String label;
  final String display;

  const _RingChart({required this.value, required this.color, required this.label, required this.display});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            children: [
              CustomPaint(size: const Size(64, 64), painter: _RingPainter(value: value, color: color)),
              Center(
                child: Text(display,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368), fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(display, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
          ],
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;

  _RingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const strokeW = 6.0;

    canvas.drawArc(
      rect, 0, 2 * math.pi, false,
      Paint()
        ..color = const Color(0xFFF1F3F4)
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect, -math.pi / 2, 2 * math.pi * value, false,
      Paint()
        ..color = color
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color;
}