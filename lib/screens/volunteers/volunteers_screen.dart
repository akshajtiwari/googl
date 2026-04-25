import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../models/volunteer_model.dart';
import '../../widgets/sidebar.dart';

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _availabilityFilter = 'All';
  Volunteer? _selected;

  @override
  void initState() {
    super.initState();
    _selected = mockVolunteers.isNotEmpty ? mockVolunteers.first : null;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Volunteer> get _filteredVolunteers {
    return mockVolunteers.where((v) {
      if (_availabilityFilter != 'All' &&
          v.availability.label != _availabilityFilter) {
        return false;
      }

      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;

      return v.name.toLowerCase().contains(q) ||
          v.id.toLowerCase().contains(q) ||
          v.area.toLowerCase().contains(q) ||
          v.skills.any((s) => s.toLowerCase().contains(q));
    }).toList();
  }

  Map<String, _AreaStat> get _areaStats {
    final map = <String, _AreaStat>{};

    for (final v in mockVolunteers) {
      final current = map[v.area] ?? _AreaStat(total: 0, available: 0, busy: 0);
      map[v.area] = _AreaStat(
        total: current.total + 1,
        available: current.available +
            (v.availability == VolunteerAvailability.available ? 1 : 0),
        busy: current.busy + (v.availability == VolunteerAvailability.busy ? 1 : 0),
      );
    }

    final entries = map.entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));

    return {for (final e in entries) e.key: e.value};
  }

  Map<String, int> get _skillFrequency {
    final freq = <String, int>{};
    for (final v in mockVolunteers) {
      for (final s in v.skills) {
        freq[s] = (freq[s] ?? 0) + 1;
      }
    }

    final entries = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  Task? _currentTask(Volunteer v) {
    Task? byTaskId;
    if (v.currentTaskId != null) {
      for (final t in mockTasks) {
        if (t.id == v.currentTaskId) {
          byTaskId = t;
          break;
        }
      }
      if (byTaskId != null) return byTaskId;
    }

    for (final t in mockTasks) {
      if (t.assignedVolunteer == v.name &&
          (t.status == TaskStatus.assigned || t.status == TaskStatus.inProgress)) {
        return t;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredVolunteers;
    final selected = _selected;

    final availableCount = mockVolunteers
        .where((v) => v.availability == VolunteerAvailability.available)
        .length;
    final busyCount =
        mockVolunteers.where((v) => v.availability == VolunteerAvailability.busy).length;
    final offlineCount = mockVolunteers
        .where((v) => v.availability == VolunteerAvailability.offline)
        .length;
    final averageRating = mockVolunteers.isEmpty
        ? 0.0
        : mockVolunteers
                .map((v) => v.rating)
                .reduce((a, b) => a + b) /
            mockVolunteers.length;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.volunteers),
          Expanded(
            child: Column(
              children: [
                _TopHeader(total: mockVolunteers.length),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                label: 'Available',
                                value: '$availableCount',
                                icon: Icons.check_circle_outline,
                                color: const Color(0xFF10B981),
                                hint: 'Ready for assignment',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                label: 'Busy',
                                value: '$busyCount',
                                icon: Icons.work_outline,
                                color: const Color(0xFFF59E0B),
                                hint: 'Currently on task',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                label: 'Offline',
                                value: '$offlineCount',
                                icon: Icons.cloud_off_outlined,
                                color: const Color(0xFF6B7280),
                                hint: 'Unavailable now',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                label: 'Avg. Rating',
                                value: averageRating.toStringAsFixed(1),
                                icon: Icons.star_outline,
                                color: const Color(0xFF3B82F6),
                                hint: 'Team quality signal',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                children: [
                                  _RosterToolbar(
                                    searchCtrl: _searchCtrl,
                                    availabilityFilter: _availabilityFilter,
                                    onSearchChanged: (_) => setState(() {}),
                                    onFilterChanged: (value) {
                                      setState(() => _availabilityFilter = value);
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: filtered.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 42),
                                            child: Center(
                                              child: Text(
                                                'No volunteers match this search/filter.',
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                          )
                                        : Column(
                                            children: filtered
                                                .map(
                                                  (v) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 10),
                                                    child: _VolunteerCard(
                                                      volunteer: v,
                                                      isSelected: selected?.id == v.id,
                                                      task: _currentTask(v),
                                                      onTap: () => setState(() => _selected = v),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _VolunteerDetailPanel(
                                    volunteer: selected,
                                    task: selected == null ? null : _currentTask(selected),
                                  ),
                                  const SizedBox(height: 14),
                                  _AreaCoveragePanel(areaStats: _areaStats),
                                  const SizedBox(height: 14),
                                  _SkillCloudPanel(skillFrequency: _skillFrequency),
                                ],
                              ),
                            ),
                          ],
                        ),
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

class _TopHeader extends StatelessWidget {
  final int total;
  const _TopHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Text(
            'Volunteer Management',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$total active records',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined, size: 16),
            label: const Text('Export CSV'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt_1, size: 16),
            label: const Text('Add Volunteer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text(label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(hint,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RosterToolbar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String availabilityFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const _RosterToolbar({
    required this.searchCtrl,
    required this.availabilityFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Available', 'Busy', 'Offline'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search name, skill, area, or volunteer ID...',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Wrap(
            spacing: 6,
            children: filters
                .map(
                  (f) => ChoiceChip(
                    label: Text(f, style: const TextStyle(fontSize: 12)),
                    selected: availabilityFilter == f,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    onSelected: (_) => onFilterChanged(f),
                    side: BorderSide(
                        color: availabilityFilter == f
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  final Task? task;
  final bool isSelected;
  final VoidCallback onTap;

  const _VolunteerCard({
    required this.volunteer,
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  volunteer.name[0],
                  style: const TextStyle(
                      color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(volunteer.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primaryColor)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: volunteer.availability.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            volunteer.availability.label,
                            style: TextStyle(
                                fontSize: 11,
                                color: volunteer.availability.color,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('${volunteer.id} • ${volunteer.area}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: volunteer.skills
                          .map(
                            (s) => Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF1E40AF),
                                      fontWeight: FontWeight.w500)),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text('${volunteer.rating.toStringAsFixed(1)} rating',
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.task_alt, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text('${volunteer.completedTasks} completed',
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(width: 12),
                        Icon(Icons.work_outline,
                            size: 14,
                            color: task == null ? Colors.grey : task!.status.color),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task == null ? 'No active task' : task!.title,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolunteerDetailPanel extends StatelessWidget {
  final Volunteer? volunteer;
  final Task? task;

  const _VolunteerDetailPanel({required this.volunteer, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: volunteer == null
          ? const Text('Select a volunteer to view details')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(volunteer!.name[0],
                          style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(volunteer!.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor)),
                          Text(volunteer!.id,
                              style:
                                  const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: volunteer!.availability.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        volunteer!.availability.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: volunteer!.availability.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.place_outlined, label: 'Base area', value: volunteer!.area),
                _InfoRow(
                    icon: Icons.navigation_outlined,
                    label: 'Coordinates',
                    value:
                        '${volunteer!.lat.toStringAsFixed(3)}, ${volunteer!.lng.toStringAsFixed(3)}'),
                _InfoRow(
                    icon: Icons.star_border,
                    label: 'Rating',
                    value: '${volunteer!.rating.toStringAsFixed(1)} / 5.0'),
                _InfoRow(
                    icon: Icons.done_all,
                    label: 'Completed tasks',
                    value: '${volunteer!.completedTasks}'),
                const SizedBox(height: 10),
                const Text('Current assignment',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: task == null ? const Color(0xFFF8FAFC) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: task == null ? Colors.grey.shade300 : const Color(0xFFBFDBFE)),
                  ),
                  child: task == null
                      ? const Text('No active assignment right now',
                          style: TextStyle(fontSize: 12, color: Colors.grey))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task!.title,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8))),
                            const SizedBox(height: 4),
                            Text('${task!.area} • ${task!.status.label}',
                                style:
                                    const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                ),
                const SizedBox(height: 10),
                const Text('Skill stack',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: volunteer!.skills
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 11)),
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: BorderSide(color: Colors.grey.shade300),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ),
    );
  }
}

class _AreaCoveragePanel extends StatelessWidget {
  final Map<String, _AreaStat> areaStats;

  const _AreaCoveragePanel({required this.areaStats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Area Readiness',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
          const SizedBox(height: 6),
          const Text(
            'Quick heat signal by locality (available vs total).',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...areaStats.entries.map((entry) {
            final area = entry.key;
            final stat = entry.value;
            final readiness = stat.total == 0 ? 0.0 : stat.available / stat.total;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(area,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        '${stat.available}/${stat.total} available',
                        style: TextStyle(
                            fontSize: 11,
                            color: readiness >= 0.5
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: readiness,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      readiness >= 0.5
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SkillCloudPanel extends StatelessWidget {
  final Map<String, int> skillFrequency;

  const _SkillCloudPanel({required this.skillFrequency});

  @override
  Widget build(BuildContext context) {
    final topSkills = skillFrequency.entries.take(10).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skill Density Cloud',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
          const SizedBox(height: 6),
          const Text(
            'Bigger pill means more volunteers have that skill.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topSkills.map((e) {
              final font = 11.0 + (e.value * 0.6);
              final opacity = (0.15 + e.value * 0.06).clamp(0.15, 0.40);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(opacity),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${e.key} · ${e.value}',
                  style: TextStyle(
                    fontSize: font,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 7),
          Text('$label: ',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _AreaStat {
  final int total;
  final int available;
  final int busy;

  const _AreaStat({required this.total, required this.available, required this.busy});
}
