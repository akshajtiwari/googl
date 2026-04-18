import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/volunteers/volunteers_screen.dart';
import '../screens/needs/needs_screen.dart';
import '../screens/tasks/tasks_screen.dart';

class AppRoutes {
  static const dashboard = '/';
  static const volunteers = '/volunteers';
  static const needs = '/needs';
  static const tasks = '/tasks';

  static Map<String, WidgetBuilder> get routes => {
        dashboard: (_) => const DashboardScreen(),
        volunteers: (_) => const VolunteersScreen(),
        needs: (_) => const NeedsScreen(),
        tasks: (_) => const TasksScreen(),
      };
}
