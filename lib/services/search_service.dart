import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/ui_models.dart';
import '../../models/volunteer_model.dart';
import '../../models/task_model.dart';

class SearchService {
  static List<SearchResult> search(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    final List<SearchResult> results = [];
    
    // 1. Static Navigation Routes
    const pages = [
      SearchResult('Volunteers', 'Manage all volunteers', AppRoutes.volunteers, Icons.people_alt_rounded),
      SearchResult('Heatmap', 'View zone coverage heatmap', AppRoutes.heatmap, Icons.map_rounded),
      SearchResult('Assignments', 'Volunteer task assignments', AppRoutes.assignments, Icons.assignment_rounded),
      SearchResult('Needs', 'Community needs list', AppRoutes.needs, Icons.report_problem_rounded),
      SearchResult('Tasks', 'Active and pending tasks', AppRoutes.tasks, Icons.task_alt_rounded),
    ];
    results.addAll(pages.where((p) => p.title.toLowerCase().contains(q) || p.subtitle.toLowerCase().contains(q)));

    // 2. Search Volunteers
    results.addAll(mockVolunteers.where((v) {
      return v.name.toLowerCase().contains(q) || v.area.toLowerCase().contains(q) || v.skills.any((s) => s.toLowerCase().contains(q));
    }).map((v) => SearchResult(v.name, 'Volunteer • ${v.area}', AppRoutes.volunteers, Icons.person_rounded)));

    // 3. Search Tasks
    results.addAll(mockTasks.where((t) {
      return t.title.toLowerCase().contains(q) || t.area.toLowerCase().contains(q) || t.needType.toLowerCase().contains(q);
    }).map((t) => SearchResult(t.title, 'Task • ${t.status.label}', AppRoutes.tasks, Icons.task_alt_rounded)));

    return results;
  }
}