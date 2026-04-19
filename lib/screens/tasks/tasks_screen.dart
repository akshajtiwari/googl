import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../widgets/sidebar.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import 'task_detail_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  String _search = '';
  Task? _selected;

  List<Task> get _filtered => mockTasks.where((t) {
        if (_filterStatus != null && t.status != _filterStatus) return false;
        if (_filterPriority != null && t.priority != _filterPriority) return false;
        if (_search.isNotEmpty &&
            !t.title.toLowerCase().contains(_search.toLowerCase()) &&
            !t.area.toLowerCase().contains(_search.toLowerCase())) return false;
        return true;
      }).toList();

  // Summary counts
  int _count(TaskStatus s) => mockTasks.where((t) => t.status == s).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.tasks),

          // ── Main content ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  child: Row(
                    children: [
                      const Text('Task Management',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor)),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {}, // hook up create form later
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Status summary cards ─────────────────────
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: TaskStatus.values.map((s) => _StatusSummaryCard(
                              status: s,
                              count: _count(s),
                              isActive: _filterStatus == s,
                              onTap: () => setState(() =>
                                  _filterStatus = _filterStatus == s ? null : s),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Search + filter bar ──────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (v) => setState(() => _search = v),
                                decoration: InputDecoration(
                                  hintText: 'Search tasks by title or area...',
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _PriorityFilter(
                              selected: _filterPriority,
                              onChanged: (p) =>
                                  setState(() => _filterPriority = p),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Task list ────────────────────────────────
                        if (_filtered.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Text('No tasks match your filters.',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        else
                          ...(_filtered.map((task) => _TaskCard(
                                task: task,
                                isSelected: _selected?.id == task.id,
                                onTap: () {
                                  setState(() => _selected = task);
                                  _openDetail(task);
                                },
                              ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(Task task) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          child: TaskDetailSheet(
            task: task,
            onTaskUpdated: () => setState(() {}),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }
}

// ── Status summary card ───────────────────────────────────────────────────
class _StatusSummaryCard extends StatelessWidget {
  final TaskStatus status;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusSummaryCard({
    required this.status,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? status.color.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? status.color : Colors.grey.shade200,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: status.color)),
              const SizedBox(height: 2),
              Text(status.label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
}

// ── Priority filter dropdown ──────────────────────────────────────────────
class _PriorityFilter extends StatelessWidget {
  final TaskPriority? selected;
  final void Function(TaskPriority?) onChanged;

  const _PriorityFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<TaskPriority?>(
            value: selected,
            hint: const Text('Priority', style: TextStyle(fontSize: 13)),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Priorities')),
              ...TaskPriority.values.map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: p.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(p.label),
                    ]),
                  )),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}

// ── Task card ─────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.deadline.isBefore(DateTime.now()) &&
        task.status != TaskStatus.verified;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Priority indicator bar
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: task.priority.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),

            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(task.id,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: task.needType == 'Food'
                              ? const Color(0xFFFEF3C7)
                              : task.needType == 'Medical'
                                  ? const Color(0xFFEFF6FF)
                                  : task.needType == 'Shelter'
                                      ? const Color(0xFFFFF7ED)
                                      : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(task.needType,
                            style: const TextStyle(fontSize: 10)),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.warning_amber,
                            size: 14, color: Colors.red),
                        const Text(' Overdue',
                            style:
                                TextStyle(fontSize: 11, color: Colors.red)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(task.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primaryColor)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(task.area,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.person, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(task.assignedVolunteer ?? 'Unassigned',
                        style: TextStyle(
                            fontSize: 12,
                            color: task.assignedVolunteer == null
                                ? Colors.orange
                                : Colors.grey)),
                  ]),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Status + deadline
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(task.status),
                const SizedBox(height: 6),
                Text(
                  _daysLabel(task.deadline),
                  style: TextStyle(
                      fontSize: 11,
                      color: isOverdue ? Colors.red : Colors.grey),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right,
                    size: 18, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _daysLabel(DateTime dt) {
    final diff = dt.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue by ${-diff}d';
    if (diff == 0) return 'Due today';
    return 'Due in ${diff}d';
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: status.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: status.color.withOpacity(0.3)),
        ),
        child: Text(status.label,
            style: TextStyle(
                fontSize: 11,
                color: status.color,
                fontWeight: FontWeight.bold)),
      );
}