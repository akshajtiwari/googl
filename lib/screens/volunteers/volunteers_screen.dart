import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/sidebar.dart';
import '../../services/volunteer_mock_data.dart';
import '../../models/volunteer_entry.dart';
import 'volunteer_details_scren.dart';
import '../../widgets/top_bar.dart'; // Reusing your global TopBar

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  String _searchQuery = '';
  
  List<VolunteerEntry> get _filteredData {
    if (_searchQuery.isEmpty) return VolunteerMockData.entries;
    return VolunteerMockData.entries.where((v) => 
      v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      v.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      v.zone.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredVolunteers;
    final selected = _selected;

    final availableCount = mockVolunteers
        .where((v) => v.availability == VolunteerAvailability.available)
        .length;
    final busyCount =
        mockVolunteers.where((v) => v.availability == VolunteerAvailability.busy).length;
    final offlineCount = mockVolunteers
        .where((v) => v.availability == VolunteerAvailability.offline)
        .length;
    final averageRating = mockVolunteers.isEmpty
        ? 0.0
        : mockVolunteers
                .map((v) => v.rating)
                .reduce((a, b) => a + b) /
            mockVolunteers.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Google Cloud background
      body: Row(
        children: [
          const Sidebar(currentRoute: '/volunteers'),
          Expanded(
            child: Column(
              children: [
                const TopBar(), // Global App Top Bar
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Roster Header & Search
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Text('Volunteer Directory', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
                              const Spacer(),
                              
                              // Page-Specific Search Bar
                              Container(
                                width: 280,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFDADCE0)),
                                ),
                                child: TextField(
                                  onChanged: (v) => setState(() => _searchQuery = v),
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF202124)),
                                  decoration: const InputDecoration(
                                    hintText: 'Search by name, role, or zone...',
                                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF5F6368)),
                                    prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF5F6368)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Filter Button
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.filter_list_rounded, size: 16),
                                label: const Text('Filters'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF5F6368),
                                  side: const BorderSide(color: Color(0xFFDADCE0)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Add Button
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.person_add_rounded, size: 16),
                                label: const Text('Add Volunteer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A73E8),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Divider(height: 1, color: Color(0xFFDADCE0)),
                        
                        // Table Headers
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          color: const Color(0xFFF8F9FA),
                          child: Row(
                            children: const [
                              Expanded(flex: 3, child: Text('Volunteer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                              Expanded(flex: 2, child: Text('Role / Zone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                              Expanded(flex: 2, child: Text('Logged Hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                              Expanded(flex: 1, child: SizedBox()), // Action column
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFDADCE0)),
                        
                        // Table Body
                        Expanded(
                          child: ListView.separated(
                            itemCount: _filteredData.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFDADCE0)),
                            itemBuilder: (context, index) {
                              final entry = _filteredData[index];
                              return InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerDetailsScreen(volunteer: entry))),
                                hoverColor: const Color(0xFFF1F3F4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Row(children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: entry.avatarColor.withOpacity(0.1),
                                            child: Text(entry.avatarInitials, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: entry.avatarColor)),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(entry.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF202124))),
                                              Text(entry.id, style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368))),
                                            ],
                                          ),
                                        ]),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(entry.role, style: const TextStyle(fontSize: 13, color: Color(0xFF202124))),
                                            Text(entry.zone, style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368))),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(alignment: Alignment.centerLeft, child: _StatusBadge(status: entry.status)),
                                      ),
                                      Expanded(flex: 2, child: Text(entry.hours, style: const TextStyle(fontSize: 13, color: Color(0xFF202124)))),
                                      const Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA0A6)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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

class _StatusBadge extends StatelessWidget {
  final VolunteerStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, textCol) = switch (status) {
      VolunteerStatus.active    => ('Active', const Color(0xFFE6F4EA), const Color(0xFF137333)), 
      VolunteerStatus.onLeave   => ('On leave', const Color(0xFFFEF7E0), const Color(0xFFB06000)), 
      VolunteerStatus.completed => ('Offline', const Color(0xFFF1F3F4), const Color(0xFF5F6368)), 
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 11, color: textCol, fontWeight: FontWeight.w600)),
    );
  }
}
