import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/volunteer_model.dart';
import '../../core/theme.dart';

class AssignmentTimelineSheet extends StatelessWidget {
  const AssignmentTimelineSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Build timeline entries from tasks that have volunteers
    final assigned = mockTasks
        .where((t) => t.assignedVolunteer != null)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Container(
      width: 400,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              const Icon(Icons.timeline, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Assignment Timeline',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Who is doing what, and when',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: assigned.length,
              itemBuilder: (_, i) {
                final task = assigned[i];
                final volunteer = mockVolunteers
                    .where((v) => v.name == task.assignedVolunteer)
                    .firstOrNull;
                final isLast = i == assigned.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline spine
                      Column(children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: task.status.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: task.status.color.withOpacity(0.4),
                                  blurRadius: 4)
                            ],
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.grey.shade200,
                            ),
                          ),
                      ]),
                      const SizedBox(width: 14),

                      // Card
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(task.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppTheme.primaryColor)),
                                ),
                                _MiniStatusBadge(task.status),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.person,
                                    size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(task.assignedVolunteer ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                if (volunteer != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: volunteer.availability.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ]),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.calendar_today,
                                    size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    'Due ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: task.deadline
                                                .isBefore(DateTime.now())
                                            ? Colors.red
                                            : Colors.grey)),
                                const SizedBox(width: 12),
                                const Icon(Icons.location_on,
                                    size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(task.area,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _MiniStatusBadge(this.status);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: status.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(status.label,
            style: TextStyle(
                fontSize: 10,
                color: status.color,
                fontWeight: FontWeight.bold)),
      );
}