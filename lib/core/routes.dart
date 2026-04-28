import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/volunteers/volunteers_screen.dart';
import '../screens/needs/needs_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/heatmap/heatmap.screen.dart';
import '../screens/assingments/assignment_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static const dashboard = '/';
  static const volunteers = '/volunteers';
  static const needs = '/needs';
  static const tasks = '/tasks';
  static const heatmap = '/heatmap';
  static const assignments = '/assignments';
  static const analytics = '/analytics';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        dashboard: (_) => const DashboardScreen(),
        volunteers: (_) => const VolunteersScreen(),
        needs: (_) => const NeedsScreen(),
        tasks: (_) => const TasksScreen(),
        heatmap: (_) => const HeatmapScreen(),
        assignments: (_) => const AssignmentsScreen(),
        analytics: (_) => const AnalyticsScreen(),
        settings: (_) => const SettingsScreen(),
      };
}
