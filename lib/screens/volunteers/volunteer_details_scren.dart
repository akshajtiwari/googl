import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/volunteer_entry.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/heatmap_preview.dart';
import '../../widgets/top_bar.dart'; 
import 'dart:math' as math;

class VolunteerDetailsScreen extends StatelessWidget {
  final VolunteerEntry volunteer;

  const VolunteerDetailsScreen({super.key, required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const Sidebar(currentRoute: '/volunteers'),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                
                // Back Breadcrumb Navigation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFDADCE0))),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF1A73E8)),
                              SizedBox(width: 4),
                              Text('Back to Directory', style: TextStyle(fontSize: 13, color: Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header Card
                        _ProfileHeader(volunteer: volunteer),
                        const SizedBox(height: 24),
                        
                        // Main Content Grid
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Col: Metrics & Tasks
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _MetricsRow(volunteer: volunteer),
                                  const SizedBox(height: 24),
                                  _TaskHistory(volunteer: volunteer),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right Col: Map Context
                            Expanded(
                              flex: 3,
                              child: _LocationCard(volunteer: volunteer),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final VolunteerEntry volunteer;
  const _ProfileHeader({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: volunteer.avatarColor.withOpacity(0.1),
            child: Text(volunteer.avatarInitials, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: volunteer.avatarColor)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(volunteer.name, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(4)),
                      child: Text(volunteer.status.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFF137333), fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Color(0xFF5F6368)),
                    const SizedBox(width: 4),
                    Text(volunteer.email, style: const TextStyle(fontSize: 13, color: Color(0xFF5F6368))),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF5F6368)),
                    const SizedBox(width: 4),
                    Text(volunteer.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF5F6368))),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.message_rounded, size: 16),
            label: const Text('Message'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.assignment_rounded, size: 16),
            label: const Text('Reassign'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final VolunteerEntry volunteer;
  const _MetricsRow({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDADCE0))),
            child: Row(
              children: [
                SizedBox(width: 48, height: 48, child: CustomPaint(painter: _RingPainter(value: volunteer.completionRate, color: const Color(0xFF1E8E3E)))),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task Completion', style: TextStyle(fontSize: 12, color: Color(0xFF5F6368), fontWeight: FontWeight.w500)),
                    Text('${(volunteer.completionRate * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDADCE0))),
            child: Row(
              children: [
                SizedBox(width: 48, height: 48, child: CustomPaint(painter: _RingPainter(value: volunteer.availabilityRate, color: const Color(0xFFF9AB00)))),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Availability', style: TextStyle(fontSize: 12, color: Color(0xFF5F6368), fontWeight: FontWeight.w500)),
                    Text('${(volunteer.availabilityRate * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final VolunteerEntry volunteer;
  const _LocationCard({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDADCE0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Current Assignment Area', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
          ),
          const Divider(height: 1, color: Color(0xFFDADCE0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF1A73E8)),
                    const SizedBox(width: 8),
                    Text(volunteer.zone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF202124))),
                  ],
                ),
                const SizedBox(height: 16),
                // 🔥 THE FIX: Strict height constraint prevents -Infinity error from flutter_map
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 200, 
                    color: const Color(0xFFF1F3F4), // Placeholder bg before map loads
                    child: const HeatmapPreview(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskHistory extends StatelessWidget {
  final VolunteerEntry volunteer;
  const _TaskHistory({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDADCE0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Activity Log', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
          ),
          const Divider(height: 1, color: Color(0xFFDADCE0)),
          if (volunteer.taskLog.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No activity recorded today.', style: TextStyle(color: Color(0xFF5F6368)))))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: volunteer.taskLog.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFDADCE0)),
              itemBuilder: (context, index) {
                final t = volunteer.taskLog[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(8)),
                        child: Icon(t.action.contains('in') || t.action.contains('Assigned') ? Icons.login_rounded : Icons.logout_rounded, size: 16, color: const Color(0xFF5F6368)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF202124))),
                            const SizedBox(height: 2),
                            Text(t.location, style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368))),
                          ],
                        ),
                      ),
                      Text(t.time, style: const TextStyle(fontSize: 13, color: Color(0xFF202124))),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Reuse RingPainter from Summary Card
class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  _RingPainter({required this.value, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - 4);
    canvas.drawArc(rect, 0, 2 * math.pi, false, Paint()..color = const Color(0xFFF1F3F4)..strokeWidth = 6.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, Paint()..color = color..strokeWidth = 6.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color;
}