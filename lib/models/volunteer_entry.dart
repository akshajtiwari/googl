import 'package:flutter/material.dart';

enum VolunteerStatus { active, onLeave, completed }

class TaskLog {
  final int index;
  final String action;
  final String time;
  final String location;
  final String? duration;
  const TaskLog(this.index, this.action, this.time, this.location, [this.duration]);
}

class VolunteerEntry {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String zone;
  final String avatarInitials;
  final Color avatarColor;
  final String checkin;
  final String checkout;
  final String hours;
  final String notes;
  final VolunteerStatus status;
  final double completionRate;
  final double availabilityRate;
  final List<TaskLog> taskLog;
  bool isChecked;
  bool isExpanded;

  VolunteerEntry({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.zone,
    required this.avatarInitials,
    required this.avatarColor,
    required this.checkin,
    required this.checkout,
    required this.hours,
    required this.notes,
    required this.status,
    required this.completionRate,
    required this.availabilityRate,
    this.taskLog = const [],
    this.isChecked = false,
    this.isExpanded = false,
  });
}
