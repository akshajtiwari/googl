import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/volunteer_model.dart';
import '../../core/theme.dart';

class AssignVolunteerDialog extends StatefulWidget {
  final Task task;
  final void Function(List<Volunteer> assigned) onAssign;

  const AssignVolunteerDialog({
    super.key,
    required this.task,
    required this.onAssign,
  });

  @override
  State<AssignVolunteerDialog> createState() => _AssignVolunteerDialogState();
}

class _AssignVolunteerDialogState extends State<AssignVolunteerDialog> {
  final Set<String> _selectedIds = {};
  bool _showSmartOnly = true;

  late final List<({Volunteer volunteer, double score, int skillMatches})> _ranked;
  late final List<Volunteer> _all;

  @override
  void initState() {
    super.initState();
    _ranked = smartMatch(
      requiredSkills: widget.task.requiredSkills,
      taskArea: widget.task.area,
      taskLat: 28.625,
      taskLng: 77.215,
    );
    _all = mockVolunteers;
  }

  List<Volunteer> get _displayList {
    if (_showSmartOnly) return _ranked.map((r) => r.volunteer).toList();
    return _all;
  }

  double _scoreFor(String id) =>
      _ranked.where((r) => r.volunteer.id == id).firstOrNull?.score ?? 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.person_add, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assign Volunteer(s)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(widget.task.title,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),

            // Required skills chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                const Text('Required: ',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                ...widget.task.requiredSkills.map((s) => Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B82F6)),
                      ),
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF3B82F6))),
                    )),
              ]),
            ),

            // Smart / All toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(children: [
                _ToggleChip(
                  label: '✨ Smart Matches',
                  active: _showSmartOnly,
                  onTap: () => setState(() => _showSmartOnly = true),
                ),
                const SizedBox(width: 8),
                _ToggleChip(
                  label: 'All Volunteers',
                  active: !_showSmartOnly,
                  onTap: () => setState(() => _showSmartOnly = false),
                ),
              ]),
            ),

            // Volunteer list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _displayList.length,
                itemBuilder: (_, i) {
                  final v = _displayList[i];
                  final selected = _selectedIds.contains(v.id);
                  final score = _scoreFor(v.id);
                  final isTop = _showSmartOnly && i == 0;

                  return GestureDetector(
                    onTap: v.availability == VolunteerAvailability.offline
                        ? null
                        : () => setState(() => selected
                            ? _selectedIds.remove(v.id)
                            : _selectedIds.add(v.id)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFEFF6FF)
                            : v.availability == VolunteerAvailability.offline
                                ? Colors.grey.shade50
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryColor
                              : isTop
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade200,
                          width: selected || isTop ? 2 : 1,
                        ),
                      ),
                      child: Row(children: [
                        // Avatar
                        Stack(children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(v.name[0],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor)),
                          ),
                          if (isTop)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.star,
                                    size: 10, color: Colors.white),
                              ),
                            ),
                        ]),
                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(v.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: v.availability ==
                                                VolunteerAvailability.offline
                                            ? Colors.grey
                                            : Colors.black87)),
                                if (isTop) ...[
                                  const SizedBox(width: 6),
                                  const Text('Best Match',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF10B981),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ]),
                              const SizedBox(height: 2),
                              Text(v.area,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: v.skills
                                    .map((s) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: widget.task.requiredSkills
                                                    .contains(s)
                                                ? const Color(0xFFDCFCE7)
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(s,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: widget
                                                          .task.requiredSkills
                                                          .contains(s)
                                                      ? const Color(0xFF166534)
                                                      : Colors.grey.shade600)),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),

                        // Right side: score + availability + checkbox
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_showSmartOnly && score > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _scoreColor(score).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                    '${(score * 100).round()}% match',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _scoreColor(score))),
                              ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    v.availability.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(v.availability.label,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: v.availability.color,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 4),
                            if (v.availability != VolunteerAvailability.offline)
                              Checkbox(
                                value: selected,
                                activeColor: AppTheme.primaryColor,
                                onChanged: (_) => setState(() => selected
                                    ? _selectedIds.remove(v.id)
                                    : _selectedIds.add(v.id)),
                              ),
                          ],
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Text(
                  _selectedIds.isEmpty
                      ? 'Select volunteer(s) above'
                      : '${_selectedIds.length} selected',
                  style: TextStyle(
                      fontSize: 13,
                      color: _selectedIds.isEmpty
                          ? Colors.grey
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 16),
                  label: Text('Assign${_selectedIds.length > 1 ? ' Team' : ''}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () {
                          final selected = mockVolunteers
                              .where((v) => _selectedIds.contains(v.id))
                              .toList();
                          widget.onAssign(selected);
                          Navigator.pop(context);
                        },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 0.75) return const Color(0xFF10B981);
    if (score >= 0.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w500)),
        ),
      );
}
