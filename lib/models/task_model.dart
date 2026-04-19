import 'package:flutter/material.dart';

enum TaskStatus { open, assigned, inProgress, completed, verified }

enum TaskPriority { low, medium, high, critical }

extension TaskStatusExt on TaskStatus {
  String get label => switch (this) {
        TaskStatus.open       => 'Open',
        TaskStatus.assigned   => 'Assigned',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.completed  => 'Completed',
        TaskStatus.verified   => 'Verified',
      };

  Color get color => switch (this) {
        TaskStatus.open       => const Color(0xFF6B7280),
        TaskStatus.assigned   => const Color(0xFF3B82F6),
        TaskStatus.inProgress => const Color(0xFFF59E0B),
        TaskStatus.completed  => const Color(0xFF10B981),
        TaskStatus.verified   => const Color(0xFF1A3A5C),
      };

  TaskStatus? get next => switch (this) {
        TaskStatus.open       => TaskStatus.assigned,
        TaskStatus.assigned   => TaskStatus.inProgress,
        TaskStatus.inProgress => TaskStatus.completed,
        TaskStatus.completed  => TaskStatus.verified,
        TaskStatus.verified   => null,
      };
}

extension TaskPriorityExt on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low      => 'Low',
        TaskPriority.medium   => 'Medium',
        TaskPriority.high     => 'High',
        TaskPriority.critical => 'Critical',
      };

  Color get color => switch (this) {
        TaskPriority.low      => const Color(0xFF10B981),
        TaskPriority.medium   => const Color(0xFFF59E0B),
        TaskPriority.high     => const Color(0xFFEF4444),
        TaskPriority.critical => const Color(0xFF7C3AED),
      };
}

class TaskHistoryEntry {
  final String action;
  final String by;
  final DateTime at;

  const TaskHistoryEntry({
    required this.action,
    required this.by,
    required this.at,
  });
}

class Task {
  final String id;
  final String title;
  final String description;
  final String area;
  final String needType;
  final List<String> requiredSkills;
  final DateTime deadline;
  final TaskPriority priority;
  TaskStatus status;
  String? assignedVolunteer;
  final List<TaskHistoryEntry> history;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.area,
    required this.needType,
    required this.requiredSkills,
    required this.deadline,
    required this.priority,
    this.status = TaskStatus.open,
    this.assignedVolunteer,
    List<TaskHistoryEntry>? history,
  }) : history = history ?? [];
}

// ── Mock data ─────────────────────────────────────────────────────────────
List<Task> mockTasks = [
  Task(
    id: 'T-001',
    title: 'Food distribution — Ward 3',
    description: 'Distribute ration kits to 40 families in the flood-affected sector of Ward 3. Kits available at Zone depot.',
    area: 'Ward 3, Delhi',
    needType: 'Food',
    requiredSkills: ['Driving', 'Logistics'],
    deadline: DateTime.now().add(const Duration(days: 2)),
    priority: TaskPriority.critical,
    status: TaskStatus.inProgress,
    assignedVolunteer: 'Riya Sharma',
    history: [
      TaskHistoryEntry(action: 'Task created', by: 'Coordinator Priya', at: DateTime.now().subtract(const Duration(days: 3))),
      TaskHistoryEntry(action: 'Assigned to Riya Sharma', by: 'Coordinator Priya', at: DateTime.now().subtract(const Duration(days: 2))),
      TaskHistoryEntry(action: 'Status → In Progress', by: 'Riya Sharma', at: DateTime.now().subtract(const Duration(hours: 5))),
    ],
  ),
  Task(
    id: 'T-002',
    title: 'Medical camp setup — Zone 4B',
    description: 'Set up temporary medical camp. Coordinate with Dr. Mehta team on arrival. Requires basic first-aid trained volunteers.',
    area: 'Zone 4B, Delhi',
    needType: 'Medical',
    requiredSkills: ['First Aid', 'Medical'],
    deadline: DateTime.now().add(const Duration(days: 1)),
    priority: TaskPriority.high,
    status: TaskStatus.assigned,
    assignedVolunteer: 'Arjun Mehta',
    history: [
      TaskHistoryEntry(action: 'Task created', by: 'Coordinator Rahul', at: DateTime.now().subtract(const Duration(days: 1))),
      TaskHistoryEntry(action: 'Assigned to Arjun Mehta', by: 'Coordinator Rahul', at: DateTime.now().subtract(const Duration(hours: 12))),
    ],
  ),
  Task(
    id: 'T-003',
    title: 'Shelter assessment — Ward 7',
    description: 'Survey 20 temporary shelters for structural integrity and capacity. Submit report by deadline.',
    area: 'Ward 7, Delhi',
    needType: 'Shelter',
    requiredSkills: ['Survey', 'Reporting'],
    deadline: DateTime.now().add(const Duration(days: 4)),
    priority: TaskPriority.medium,
    status: TaskStatus.open,
    history: [
      TaskHistoryEntry(action: 'Task created', by: 'Coordinator Priya', at: DateTime.now().subtract(const Duration(hours: 6))),
    ],
  ),
  Task(
    id: 'T-004',
    title: 'Education kit delivery — Block C',
    description: 'Deliver stationery and book kits to 3 temporary schools in Block C.',
    area: 'Block C, Delhi',
    needType: 'Education',
    requiredSkills: ['Driving'],
    deadline: DateTime.now().add(const Duration(days: 6)),
    priority: TaskPriority.low,
    status: TaskStatus.completed,
    assignedVolunteer: 'Priya Singh',
    history: [
      TaskHistoryEntry(action: 'Task created', by: 'Coordinator Rahul', at: DateTime.now().subtract(const Duration(days: 5))),
      TaskHistoryEntry(action: 'Assigned to Priya Singh', by: 'Coordinator Rahul', at: DateTime.now().subtract(const Duration(days: 4))),
      TaskHistoryEntry(action: 'Status → In Progress', by: 'Priya Singh', at: DateTime.now().subtract(const Duration(days: 2))),
      TaskHistoryEntry(action: 'Status → Completed', by: 'Priya Singh', at: DateTime.now().subtract(const Duration(hours: 3))),
    ],
  ),
  Task(
    id: 'T-005',
    title: 'Water purification — Zone 2',
    description: 'Install and demonstrate water purification tablets distribution. Briefing required first.',
    area: 'Zone 2, Delhi',
    needType: 'Medical',
    requiredSkills: ['Training', 'First Aid'],
    deadline: DateTime.now().subtract(const Duration(days: 1)),
    priority: TaskPriority.high,
    status: TaskStatus.verified,
    assignedVolunteer: 'Kunal Verma',
    history: [
      TaskHistoryEntry(action: 'Task created', by: 'Coordinator Priya', at: DateTime.now().subtract(const Duration(days: 7))),
      TaskHistoryEntry(action: 'Assigned to Kunal Verma', by: 'Coordinator Priya', at: DateTime.now().subtract(const Duration(days: 6))),
      TaskHistoryEntry(action: 'Status → In Progress', by: 'Kunal Verma', at: DateTime.now().subtract(const Duration(days: 4))),
      TaskHistoryEntry(action: 'Status → Completed', by: 'Kunal Verma', at: DateTime.now().subtract(const Duration(days: 2))),
      TaskHistoryEntry(action: 'Verified by coordinator', by: 'Coordinator Priya', at: DateTime.now().subtract(const Duration(days: 1))),
    ],
  ),
];