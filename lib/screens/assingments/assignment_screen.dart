import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/volunteer_model.dart';
import '../../widgets/sidebar.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import 'assign_volunteer_dialog.dart';
import 'assingment_timeline_sheet.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String _filterTab = 'All'; // All | Unassigned | Assigned | Overdue
  String _search = '';

  // Local assignment state (mirrors mockTasks)
  final Map<String, List<String>> _assignments = {}; // taskId → volunteerNames
  final Map<String, List<String>> _reassignLog = {}; // taskId → reason log

  @override
  void initState() {
    super.initState();
    // Seed from existing mock data
    for (final t in mockTasks) {
      if (t.assignedVolunteer != null) {
        _assignments[t.id] = [t.assignedVolunteer!];
      }
    }
  }

  List<Task> get _filtered {
    return mockTasks.where((t) {
      final hasAssignment =
          _assignments.containsKey(t.id) && _assignments[t.id]!.isNotEmpty;
      final isOverdue = t.deadline.isBefore(DateTime.now());

      if (_filterTab == 'Unassigned' && hasAssignment) return false;
      if (_filterTab == 'Assigned' && !hasAssignment) return false;
      if (_filterTab == 'Overdue' && !isOverdue) return false;

      if (_search.isNotEmpty &&
          !t.title.toLowerCase().contains(_search.toLowerCase()) &&
          !t.area.toLowerCase().contains(_search.toLowerCase())) return false;

      return true;
    }).toList();
  }

  void _openAssignDialog(Task task) {
    showDialog(
      context: context,
      builder: (_) => AssignVolunteerDialog(
        task: task,
        onAssign: (volunteers) {
          setState(() {
            _assignments[task.id] = volunteers.map((v) => v.name).toList();
            task.assignedVolunteer = volunteers.first.name;
            if (task.status == TaskStatus.open) {
              task.status = TaskStatus.assigned;
            }
            task.history.add(TaskHistoryEntry(
              action: 'Assigned to ${volunteers.map((v) => v.name).join(', ')}',
              by: 'Coordinator',
              at: DateTime.now(),
            ));
          });
          _showSnack(
              '✅ Assigned ${volunteers.map((v) => v.name).join(', ')} to ${task.title}');
        },
      ),
    );
  }

  void _openReassignDialog(Task task) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reassign Task',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current: ${_assignments[task.id]?.join(', ') ?? 'None'}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 14),
            const Text('Reason for reassignment:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Volunteer unavailable, skill mismatch...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context);
              // Log the reason then open assign dialog
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                _reassignLog.putIfAbsent(task.id, () => []);
                _reassignLog[task.id]!.add(
                    '${DateTime.now().day}/${DateTime.now().month}: $reason');
                task.history.add(TaskHistoryEntry(
                  action: 'Reassignment requested: $reason',
                  by: 'Coordinator',
                  at: DateTime.now(),
                ));
              }
              _openAssignDialog(task);
            },
            child: const Text('Continue to Assign'),
          ),
        ],
      ),
    );
  }

  void _unassign(Task task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Unassign Volunteer?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
            'Remove ${_assignments[task.id]?.join(', ')} from "${task.title}"?',
            style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              setState(() {
                final prev = _assignments[task.id]?.join(', ') ?? '';
                _assignments.remove(task.id);
                task.assignedVolunteer = null;
                if (task.status == TaskStatus.assigned) {
                  task.status = TaskStatus.open;
                }
                task.history.add(TaskHistoryEntry(
                  action: 'Unassigned ($prev)',
                  by: 'Coordinator',
                  at: DateTime.now(),
                ));
              });
              Navigator.pop(context);
              _showSnack('Volunteer unassigned from ${task.title}');
            },
            child: const Text('Unassign'),
          ),
        ],
      ),
    );
  }

  void _openTimeline() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => const Align(
        alignment: Alignment.centerRight,
        child: Material(child: AssignmentTimelineSheet()),
      ),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final unassignedCount =
        mockTasks.where((t) => !(_assignments.containsKey(t.id))).length;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.assignments),
          Expanded(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  child: Row(children: [
                    const Text('Assignment & Matching',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor)),
                    const SizedBox(width: 12),
                    if (unassignedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$unassignedCount unassigned',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.bold)),
                      ),
                    const Spacer(),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.timeline, size: 16),
                      label: const Text('Timeline View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _openTimeline,
                    ),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Summary cards ──────────────────────────────
                        Row(children: [
                          _SummaryCard(
                            label: 'Total Tasks',
                            value: '${mockTasks.length}',
                            color: AppTheme.primaryColor,
                            icon: Icons.task,
                          ),
                          const SizedBox(width: 14),
                          _SummaryCard(
                            label: 'Assigned',
                            value: '${_assignments.length}',
                            color: const Color(0xFF10B981),
                            icon: Icons.person_pin_circle,
                          ),
                          const SizedBox(width: 14),
                          _SummaryCard(
                            label: 'Unassigned',
                            value: '$unassignedCount',
                            color: const Color(0xFFEF4444),
                            icon: Icons.person_off,
                          ),
                          const SizedBox(width: 14),
                          _SummaryCard(
                            label: 'Available Volunteers',
                            value:
                                '${mockVolunteers.where((v) => v.availability == VolunteerAvailability.available).length}',
                            color: const Color(0xFF3B82F6),
                            icon: Icons.people,
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // ── Filter tabs + search ───────────────────────
                        Row(children: [
                          ...[
                            'All',
                            'Unassigned',
                            'Assigned',
                            'Overdue'
                          ].map((tab) => _TabButton(
                                label: tab,
                                active: _filterTab == tab,
                                onTap: () => setState(() => _filterTab = tab),
                              )),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(
                                hintText: 'Search by title or area...',
                                prefixIcon: const Icon(Icons.search, size: 18),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // ── Task assignment cards ──────────────────────
                        if (_filtered.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text('No tasks match this filter.',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        else
                          ..._filtered.map((task) {
                            final volunteers = _assignments[task.id] ?? [];
                            final isAssigned = volunteers.isNotEmpty;
                            final isOverdue =
                                task.deadline.isBefore(DateTime.now());
                            final logs = _reassignLog[task.id] ?? [];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: !isAssigned
                                      ? const Color(0xFFFCA5A5)
                                      : Colors.grey.shade200,
                                  width: !isAssigned ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row
                                  Row(children: [
                                    Container(
                                      width: 4,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: task.priority.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Text(task.id,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey)),
                                            const SizedBox(width: 8),
                                            _MiniChip(task.needType,
                                                const Color(0xFF3B82F6)),
                                            const SizedBox(width: 8),
                                            _MiniChip(task.priority.label,
                                                task.priority.color),
                                            if (isOverdue) ...[
                                              const SizedBox(width: 8),
                                              _MiniChip('Overdue', Colors.red),
                                            ],
                                          ]),
                                          const SizedBox(height: 4),
                                          Text(task.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color:
                                                      AppTheme.primaryColor)),
                                          const SizedBox(height: 2),
                                          Text(
                                              '${task.area}  •  Due ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color:
                                            task.status.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: task.status.color
                                                .withOpacity(0.3)),
                                      ),
                                      child: Text(task.status.label,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: task.status.color,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ]),

                                  const SizedBox(height: 14),
                                  const Divider(height: 1),
                                  const SizedBox(height: 14),

                                  // Assignment row
                                  Row(children: [
                                    // Current assignment
                                    Expanded(
                                      child: isAssigned
                                          ? Wrap(
                                              spacing: 8,
                                              children: volunteers
                                                  .map((name) => _VolunteerChip(
                                                      name: name))
                                                  .toList(),
                                            )
                                          : Row(children: [
                                              const Icon(Icons.person_off,
                                                  size: 16,
                                                  color: Colors.orange),
                                              const SizedBox(width: 6),
                                              const Text(
                                                  'No volunteer assigned',
                                                  style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ]),
                                    ),

                                    // Action buttons
                                    Row(children: [
                                      if (!isAssigned)
                                        _ActionButton(
                                          label: '✨ Smart Assign',
                                          color: AppTheme.primaryColor,
                                          onTap: () => _openAssignDialog(task),
                                        ),
                                      if (isAssigned) ...[
                                        _ActionButton(
                                          label: 'Reassign',
                                          color: const Color(0xFFF59E0B),
                                          onTap: () =>
                                              _openReassignDialog(task),
                                        ),
                                        const SizedBox(width: 8),
                                        _ActionButton(
                                          label: 'Unassign',
                                          color: const Color(0xFFEF4444),
                                          onTap: () => _unassign(task),
                                        ),
                                      ],
                                    ]),
                                  ]),

                                  // Required skills
                                  if (task.requiredSkills.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      const Text('Skills needed: ',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      ...task.requiredSkills.map((s) =>
                                          Container(
                                            margin:
                                                const EdgeInsets.only(right: 4),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(s,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF3B82F6))),
                                          )),
                                    ]),
                                  ],

                                  // Reassign log
                                  if (logs.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFDE68A)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('📋 Reassignment log:',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFB45309))),
                                          ...logs.map((l) => Text('• $l',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFB45309)))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
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
}

// ── Supporting widgets ────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          ]),
        ),
      );
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabButton(
      {required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: active ? AppTheme.primaryColor : Colors.grey.shade300),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w500)),
        ),
      );
}

class _VolunteerChip extends StatelessWidget {
  final String name;
  const _VolunteerChip({required this.name});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person, size: 13, color: Color(0xFF3B82F6)),
          const SizedBox(width: 5),
          Text(name,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ),
      );
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: color)),
      );
}
