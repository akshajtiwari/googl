import 'package:flutter/material.dart';

enum VolunteerAvailability { available, busy, offline }

extension VolAvailExt on VolunteerAvailability {
  String get label => switch (this) {
        VolunteerAvailability.available => 'Available',
        VolunteerAvailability.busy      => 'Busy',
        VolunteerAvailability.offline   => 'Offline',
      };

  Color get color => switch (this) {
        VolunteerAvailability.available => const Color(0xFF10B981),
        VolunteerAvailability.busy      => const Color(0xFFF59E0B),
        VolunteerAvailability.offline   => const Color(0xFF6B7280),
      };
}

class Volunteer {
  final String id;
  final String name;
  final String area;
  final double lat;
  final double lng;
  final List<String> skills;
  VolunteerAvailability availability;
  String? currentTaskId;
  int completedTasks;
  double rating; // 0.0 - 5.0

  Volunteer({
    required this.id,
    required this.name,
    required this.area,
    required this.lat,
    required this.lng,
    required this.skills,
    this.availability = VolunteerAvailability.available,
    this.currentTaskId,
    this.completedTasks = 0,
    this.rating = 4.5,
  });
}

// ── Mock volunteers ───────────────────────────────────────────────────────
final List<Volunteer> mockVolunteers = [
  Volunteer(id: 'V-01', name: 'Riya Sharma',   area: 'Ward 3, Delhi',   lat: 28.622, lng: 77.218, skills: ['Driving', 'Logistics', 'First Aid'],   availability: VolunteerAvailability.available,  completedTasks: 12, rating: 4.8),
  Volunteer(id: 'V-02', name: 'Arjun Mehta',   area: 'Zone 4B, Delhi',  lat: 28.638, lng: 77.228, skills: ['Medical', 'First Aid', 'Training'],     availability: VolunteerAvailability.busy,       currentTaskId: 'T-002', completedTasks: 8, rating: 4.6),
  Volunteer(id: 'V-03', name: 'Priya Singh',   area: 'Block C, Delhi',  lat: 28.612, lng: 77.205, skills: ['Driving', 'Education', 'Reporting'],   availability: VolunteerAvailability.available,  completedTasks: 15, rating: 4.9),
  Volunteer(id: 'V-04', name: 'Kunal Verma',   area: 'Zone 2, Delhi',   lat: 28.648, lng: 77.200, skills: ['Training', 'Medical', 'Survey'],        availability: VolunteerAvailability.offline,                        completedTasks: 5,  rating: 4.2),
  Volunteer(id: 'V-05', name: 'Anjali Gupta',  area: 'Ward 7, Delhi',   lat: 28.625, lng: 77.215, skills: ['Survey', 'Reporting', 'Logistics'],    availability: VolunteerAvailability.available,  completedTasks: 9,  rating: 4.5),
  Volunteer(id: 'V-06', name: 'Rohan Das',     area: 'Ward 3, Delhi',   lat: 28.621, lng: 77.212, skills: ['Driving', 'Logistics'],                availability: VolunteerAvailability.available,  completedTasks: 3,  rating: 4.0),
  Volunteer(id: 'V-07', name: 'Sneha Iyer',    area: 'Zone 4B, Delhi',  lat: 28.640, lng: 77.230, skills: ['Medical', 'First Aid'],                availability: VolunteerAvailability.available,  completedTasks: 7,  rating: 4.7),
  Volunteer(id: 'V-08', name: 'Dev Kapoor',    area: 'Block C, Delhi',  lat: 28.614, lng: 77.208, skills: ['Education', 'Training', 'Reporting'],  availability: VolunteerAvailability.busy,       currentTaskId: 'T-001', completedTasks: 11, rating: 4.4),
];

// ── Smart match scoring ───────────────────────────────────────────────────
/// Returns volunteers sorted by match score for a given task's required skills + area.
/// Score: skill overlap (60%) + proximity (30%) + rating (10%)
List<({Volunteer volunteer, double score, int skillMatches})> smartMatch({
  required List<String> requiredSkills,
  required String taskArea,
  required double taskLat,
  required double taskLng,
}) {
  final results = mockVolunteers
      .where((v) => v.availability == VolunteerAvailability.available)
      .map((v) {
    final matched = v.skills.where((s) => requiredSkills.contains(s)).length;
    final skillScore = requiredSkills.isEmpty
        ? 1.0
        : matched / requiredSkills.length;

    // Simple distance score (lower distance = higher score, capped at 1.0)
    final dist = _distance(v.lat, v.lng, taskLat, taskLng);
    final proximityScore = (1 - (dist / 20.0)).clamp(0.0, 1.0);

    final ratingScore = v.rating / 5.0;

    final total = (skillScore * 0.6) + (proximityScore * 0.3) + (ratingScore * 0.1);
    return (volunteer: v, score: total, skillMatches: matched);
  }).toList();

  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
}

double _distance(double lat1, double lng1, double lat2, double lng2) {
  // Rough km estimate (good enough for UI scoring)
  final dlat = (lat1 - lat2).abs() * 111;
  final dlng = (lng1 - lng2).abs() * 111;
  return (dlat * dlat + dlng * dlng) < 0 ? 0 : _sqrt(dlat * dlat + dlng * dlng);
}

double _sqrt(double x) {
  if (x <= 0) return 0;
  double r = x;
  for (int i = 0; i < 20; i++) r = (r + x / r) / 2;
  return r;
}