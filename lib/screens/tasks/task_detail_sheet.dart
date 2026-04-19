import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../core/theme.dart';

class TaskDetailSheet extends StatefulWidget {
  final Task task;
  final VoidCallback onTaskUpdated;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  late Task task;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  void _advanceStatus() {
    final next = task.status.next;
    if (next == null) return;

    final action = next == TaskStatus.verified
        ? 'Verified by coordinator'
        : 'Status → ${next.label}';

    setState(() {
      task.status = next;
      task.history.add(TaskHistoryEntry(
        action: action,
        by: 'Coordinator',
        at: DateTime.now(),
      ));
    });
    widget.onTaskUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final canAdvance = task.status.next != null;
    final isVerifyStep = task.status == TaskStatus.completed;

    return Container(
      width: 420,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.id,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(task.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + Priority badges
                  Row(
                    children: [
                      _Badge(label: task.status.label, color: task.status.color),
                      const SizedBox(width: 8),
                      _Badge(label: task.priority.label, color: task.priority.color),
                      const SizedBox(width: 8),
                      _Badge(label: task.needType, color: AppTheme.accentColor),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _SectionLabel('Description'),
                  const SizedBox(height: 6),
                  Text(task.description,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.5)),
                  const SizedBox(height: 20),

                  // Details grid
                  _DetailRow(Icons.location_on, 'Area', task.area),
                  _DetailRow(Icons.calendar_today, 'Deadline',
                      _formatDate(task.deadline),
                      valueColor: task.deadline.isBefore(DateTime.now())
                          ? Colors.red
                          : null),
                  _DetailRow(Icons.person, 'Assigned To',
                      task.assignedVolunteer ?? '— Unassigned',
                      valueColor: task.assignedVolunteer == null ? Colors.orange : null),
                  const SizedBox(height: 16),

                  // Required Skills
                  _SectionLabel('Required Skills'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: task.requiredSkills
                        .map((s) => Chip(
                              label: Text(s,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: const Color(0xFFEFF6FF),
                              side: const BorderSide(color: Color(0xFF3B82F6)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Status Pipeline
                  _SectionLabel('Status Pipeline'),
                  const SizedBox(height: 12),
                  _StatusPipeline(current: task.status),
                  const SizedBox(height: 24),

                  // History Log
                  _SectionLabel('History Log'),
                  const SizedBox(height: 8),
                  ...task.history.reversed.map((e) => _HistoryEntry(entry: e)),
                ],
              ),
            ),
          ),

          // ── Action Button ──────────────────────────────────────────
          if (canAdvance)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(isVerifyStep ? Icons.verified : Icons.arrow_forward, size: 18),
                  label: Text(isVerifyStep
                      ? 'Mark as Verified ✓'
                      : 'Advance to ${task.status.next!.label}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerifyStep
                        ? const Color(0xFF10B981)
                        : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _advanceStatus,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = dt.difference(DateTime.now()).inDays;
    final base = '${dt.day}/${dt.month}/${dt.year}';
    if (diff < 0) return '$base (overdue)';
    if (diff == 0) return '$base (today)';
    if (diff == 1) return '$base (tomorrow)';
    return '$base (in $diff days)';
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppTheme.primaryColor));
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow(this.icon, this.label, this.value, {this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1A3A5C))),
          ),
        ]),
      );
}

class _StatusPipeline extends StatelessWidget {
  final TaskStatus current;
  const _StatusPipeline({required this.current});

  @override
  Widget build(BuildContext context) {
    final statuses = TaskStatus.values;
    return Row(
      children: statuses.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isDone = s.index <= current.index;
        final isLast = i == statuses.length - 1;

        return Expanded(
          child: Row(children: [
            Expanded(
              child: Column(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDone ? s.color : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDone ? s.color : Colors.grey.shade300,
                        width: 2),
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.circle_outlined,
                    size: 14,
                    color: isDone ? Colors.white : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(s.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 9,
                        color: isDone ? s.color : Colors.grey,
                        fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
              ]),
            ),
            if (!isLast)
              Container(
                height: 2,
                width: 8,
                color: s.index < current.index
                    ? current.color
                    : Colors.grey.shade300,
              ),
          ]),
        );
      }).toList(),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  final TaskHistoryEntry entry;
  const _HistoryEntry({required this.entry});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.accentColor, shape: BoxShape.circle)),
              Container(
                  width: 1, height: 28, color: Colors.grey.shade200),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.action,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('${entry.by} · ${_timeAgo(entry.at)}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}