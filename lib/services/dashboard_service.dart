import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/ui_models.dart';

class DashboardService {
  static const stats = [
    StatMeta('142', 'Total Volunteers', Icons.people_alt_rounded, Color(0xFF3B82F6), AppRoutes.volunteers),
    StatMeta('38', 'Active Tasks', Icons.task_alt_rounded, Color(0xFF10B981), AppRoutes.tasks),
    StatMeta('21', 'Pending Needs', Icons.warning_amber_rounded, Color(0xFFF59E0B), AppRoutes.needs),
    StatMeta('74%', 'Zone Coverage', Icons.public_rounded, Color(0xFF06B6D4), AppRoutes.heatmap),
  ];
}