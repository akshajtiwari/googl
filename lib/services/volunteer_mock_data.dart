import 'package:flutter/material.dart';
import '../models/volunteer_entry.dart';

class VolunteerMockData {
  static final List<VolunteerEntry> entries = [
    VolunteerEntry(
      id: 'VOL-001', name: 'Riya Sharma', email: 'riya.s@example.com', phone: '+91 98765 43210',
      role: 'Medical', zone: 'Zone 4B', avatarInitials: 'RS', avatarColor: const Color(0xFF1A73E8),
      checkin: '08:15 AM', checkout: '-:-', hours: '3:40', notes: 'Deployed at main camp.',
      status: VolunteerStatus.active, completionRate: 0.92, availabilityRate: 0.85,
      taskLog: const [
        TaskLog(1, 'Check in', '08:15 AM', 'Zone 4B Med Tent'),
        TaskLog(2, 'Assigned Task', '09:00 AM', 'Zone 4B Med Tent', 'Ongoing'),
      ],
    ),
    VolunteerEntry(
      id: 'VOL-002', name: 'Arjun Mehta', email: 'arjun.m@example.com', phone: '+91 91234 56789',
      role: 'Food Dist.', zone: 'Zone 2', avatarInitials: 'AM', avatarColor: const Color(0xFF1E8E3E),
      checkin: '07:00 AM', checkout: '01:30 PM', hours: '6:30', notes: 'Multi-zone route.',
      status: VolunteerStatus.completed, completionRate: 1.0, availabilityRate: 0.60,
      taskLog: const [
        TaskLog(1, 'Check in', '07:00 AM', 'Zone 2 HQ'),
        TaskLog(2, 'Check out', '10:00 AM', 'Zone 2 HQ', '3:00'),
        TaskLog(3, 'Check in', '10:30 AM', 'Zone 5 Camp'),
        TaskLog(4, 'Check out', '01:30 PM', 'Zone 5 Camp', '3:00'),
      ],
    ),
    VolunteerEntry(
      id: 'VOL-003', name: 'Meera Singh', email: 'meera.s@example.com', phone: '+91 99887 76655',
      role: 'Shelter', zone: 'Zone 7', avatarInitials: 'MS', avatarColor: const Color(0xFF9334E6),
      checkin: '09:00 AM', checkout: '03:00 PM', hours: '6:00', notes: 'Night shift prep.',
      status: VolunteerStatus.completed, completionRate: 0.88, availabilityRate: 0.90,
    ),
    VolunteerEntry(
      id: 'VOL-004', name: 'Dev Patel', email: 'dev.p@example.com', phone: '+91 98765 12345',
      role: 'Logistics', zone: 'Zone 1', avatarInitials: 'DP', avatarColor: const Color(0xFFF9AB00),
      checkin: '06:30 AM', checkout: '12:00 PM', hours: '5:30', notes: 'Vehicle maintenance.',
      status: VolunteerStatus.onLeave, completionRate: 0.75, availabilityRate: 0.40,
    ),
  ];
}