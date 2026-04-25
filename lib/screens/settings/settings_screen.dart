import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';

// ── Data models ───────────────────────────────────────────────────────────

class NeedCategory {
  String name;
  Color color;
  bool enabled;
  NeedCategory({required this.name, required this.color, this.enabled = true});
}

class CoordinatorAccount {
  String name;
  String email;
  String role; // 'Super Admin' | 'Coordinator' | 'Viewer'
  bool active;
  CoordinatorAccount({
    required this.name,
    required this.email,
    required this.role,
    this.active = true,
  });
}

// ── Settings Screen ───────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _activeSection = 0;

  // ── Section 1: Org Info ──────────────────────────────────────────────
  final _orgNameCtrl    = TextEditingController(text: 'NexusAid Foundation');
  final _orgEmailCtrl   = TextEditingController(text: 'admin@nexusaid.org');
  final _orgCityCtrl    = TextEditingController(text: 'New Delhi');
  final _orgPhoneCtrl   = TextEditingController(text: '+91 98765 43210');
  bool _orgSaved = false;

  // ── Section 2: Need Categories ───────────────────────────────────────
  final List<NeedCategory> _categories = [
    NeedCategory(name: 'Food',      color: const Color(0xFFEF4444)),
    NeedCategory(name: 'Medical',   color: const Color(0xFF3B82F6)),
    NeedCategory(name: 'Shelter',   color: const Color(0xFFF59E0B)),
    NeedCategory(name: 'Education', color: const Color(0xFF10B981)),
  ];
  final _newCategoryCtrl = TextEditingController();
  Color _newCategoryColor = const Color(0xFF8B5CF6);

  // ── Section 3: Alert Thresholds ──────────────────────────────────────
  double _unmetNeedsThreshold  = 10;
  double _minVolunteersThreshold = 2;
  double _overdueGraceDays      = 1;
  bool _thresholdSaved = false;

  // ── Section 4: Coordinators ──────────────────────────────────────────
  final List<CoordinatorAccount> _coordinators = [
    CoordinatorAccount(name: 'Priya Nair',    email: 'priya@nexusaid.org',   role: 'Super Admin'),
    CoordinatorAccount(name: 'Rahul Sharma',  email: 'rahul@nexusaid.org',   role: 'Coordinator'),
    CoordinatorAccount(name: 'Ananya Gupta',  email: 'ananya@nexusaid.org',  role: 'Coordinator'),
    CoordinatorAccount(name: 'Vikram Patel',  email: 'vikram@nexusaid.org',  role: 'Viewer',       active: false),
  ];

  @override
  void dispose() {
    _orgNameCtrl.dispose();
    _orgEmailCtrl.dispose();
    _orgCityCtrl.dispose();
    _orgPhoneCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.settings),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left section nav ─────────────────────────────────
                Container(
                  width: 220,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Text('Settings',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor)),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Text('Configure your dashboard',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      _SectionNavItem(
                        icon: Icons.business,
                        label: 'Organization',
                        active: _activeSection == 0,
                        onTap: () => setState(() => _activeSection = 0),
                      ),
                      _SectionNavItem(
                        icon: Icons.category,
                        label: 'Need Categories',
                        active: _activeSection == 1,
                        onTap: () => setState(() => _activeSection = 1),
                      ),
                      _SectionNavItem(
                        icon: Icons.notifications_active,
                        label: 'Alert Thresholds',
                        active: _activeSection == 2,
                        onTap: () => setState(() => _activeSection = 2),
                      ),
                      _SectionNavItem(
                        icon: Icons.manage_accounts,
                        label: 'Coordinators',
                        active: _activeSection == 3,
                        onTap: () => setState(() => _activeSection = 3),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(width: 1, color: Colors.grey.shade200),

                // ── Right content area ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(36),
                    child: [
                      _buildOrgSection(),
                      _buildCategoriesSection(),
                      _buildThresholdsSection(),
                      _buildCoordinatorsSection(),
                    ][_activeSection],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // SECTION 1 — Organization Info
  // ════════════════════════════════════════════════════════════════════
  Widget _buildOrgSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.business,
          title: 'Organization Info',
          subtitle: 'Basic details about your NGO',
        ),
        const SizedBox(height: 28),

        // Logo placeholder
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 1.5),
              ),
              child: const Icon(Icons.business,
                  size: 36, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Organization Logo',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('PNG or JPG, max 2MB',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text('Upload Logo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(
                        color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => _showSnack('Logo upload coming soon'),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),
        _SettingsCard(
          child: Column(
            children: [
              Row(children: [
                Expanded(
                    child: _Field(
                        label: 'Organization Name',
                        controller: _orgNameCtrl,
                        icon: Icons.business_center)),
                const SizedBox(width: 20),
                Expanded(
                    child: _Field(
                        label: 'Contact Email',
                        controller: _orgEmailCtrl,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress)),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: _Field(
                        label: 'City / Region',
                        controller: _orgCityCtrl,
                        icon: Icons.location_city)),
                const SizedBox(width: 20),
                Expanded(
                    child: _Field(
                        label: 'Phone Number',
                        controller: _orgPhoneCtrl,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone)),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Row(children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
            ),
            onPressed: () {
              setState(() => _orgSaved = true);
              Future.delayed(const Duration(seconds: 2),
                  () => setState(() => _orgSaved = false));
            },
          ),
          if (_orgSaved) ...[
            const SizedBox(width: 14),
            const Icon(Icons.check_circle,
                color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 6),
            const Text('Saved',
                style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600)),
          ],
        ]),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // SECTION 2 — Need Categories
  // ════════════════════════════════════════════════════════════════════
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.category,
          title: 'Need Categories',
          subtitle:
              'These categories appear across Needs, Tasks, and the Heatmap',
        ),
        const SizedBox(height: 28),

        _SettingsCard(
          child: Column(
            children: [
              // Existing categories
              ..._categories.asMap().entries.map((e) {
                final i = e.key;
                final cat = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    // Color dot
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                          color: cat.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 14),
                    // Name
                    Expanded(
                      child: Text(cat.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                    // Toggle
                    Row(children: [
                      Text(
                          cat.enabled ? 'Active' : 'Disabled',
                          style: TextStyle(
                              fontSize: 12,
                              color: cat.enabled
                                  ? const Color(0xFF10B981)
                                  : Colors.grey)),
                      const SizedBox(width: 8),
                      Switch(
                        value: cat.enabled,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (v) =>
                            setState(() => cat.enabled = v),
                      ),
                    ]),
                    const SizedBox(width: 8),
                    // Delete (only allow if more than 1 category)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Colors.red),
                      tooltip: 'Remove category',
                      onPressed: _categories.length > 1
                          ? () => _confirmDeleteCategory(i)
                          : null,
                    ),
                  ]),
                );
              }),

              const Divider(height: 28),

              // Add new category
              Row(children: [
                // Color picker
                GestureDetector(
                  onTap: _pickColor,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _newCategoryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Icon(Icons.colorize,
                        size: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _newCategoryCtrl,
                    decoration: InputDecoration(
                      hintText: 'New category name...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _addCategory,
                ),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Text(
            '${_categories.where((c) => c.enabled).length} of ${_categories.length} categories active',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _addCategory() {
    final name = _newCategoryCtrl.text.trim();
    if (name.isEmpty) return;
    if (_categories.any(
        (c) => c.name.toLowerCase() == name.toLowerCase())) {
      _showSnack('Category "$name" already exists');
      return;
    }
    setState(() {
      _categories.add(NeedCategory(
          name: name, color: _newCategoryColor));
      _newCategoryCtrl.clear();
      _newCategoryColor = const Color(0xFF8B5CF6);
    });
    _showSnack('Category "$name" added');
  }

  void _confirmDeleteCategory(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Remove Category?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
            'Remove "${_categories[index].name}"? This will affect all tasks and needs using this category.',
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
              setState(() => _categories.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _pickColor() {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
      const Color(0xFF6366F1),
      const Color(0xFF84CC16),
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Pick a Color',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors
              .map((c) => GestureDetector(
                    onTap: () {
                      setState(() => _newCategoryColor = c);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle),
                      child: _newCategoryColor == c
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // SECTION 3 — Alert Thresholds
  // ════════════════════════════════════════════════════════════════════
  Widget _buildThresholdsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.notifications_active,
          title: 'Alert Thresholds',
          subtitle:
              'Controls when the heatmap flags zones and when alerts trigger',
        ),
        const SizedBox(height: 28),

        _SettingsCard(
          child: Column(
            children: [
              _ThresholdSlider(
                label: 'Unmet Needs per Zone',
                description:
                    'Flag a zone on the heatmap when unmet needs exceed this number',
                icon: Icons.report_problem,
                iconColor: const Color(0xFFEF4444),
                value: _unmetNeedsThreshold,
                min: 1,
                max: 50,
                divisions: 49,
                unit: 'needs',
                onChanged: (v) =>
                    setState(() => _unmetNeedsThreshold = v),
              ),
              const Divider(height: 32),
              _ThresholdSlider(
                label: 'Minimum Volunteers per Zone',
                description:
                    'Mark a zone as underserved when active volunteers fall below this',
                icon: Icons.people,
                iconColor: const Color(0xFFF59E0B),
                value: _minVolunteersThreshold,
                min: 1,
                max: 10,
                divisions: 9,
                unit: 'volunteers',
                onChanged: (v) =>
                    setState(() => _minVolunteersThreshold = v),
              ),
              const Divider(height: 32),
              _ThresholdSlider(
                label: 'Task Overdue Grace Period',
                description:
                    'Days after deadline before a task is flagged as overdue',
                icon: Icons.timer_off,
                iconColor: const Color(0xFF8B5CF6),
                value: _overdueGraceDays,
                min: 0,
                max: 7,
                divisions: 7,
                unit: 'days',
                onChanged: (v) =>
                    setState(() => _overdueGraceDays = v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Preview box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline,
                color: Color(0xFF16A34A), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Heatmap will highlight zones with more than '
                '${_unmetNeedsThreshold.round()} unmet needs and fewer than '
                '${_minVolunteersThreshold.round()} volunteers. '
                'Tasks become overdue after ${_overdueGraceDays.round()} day(s) past deadline.',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF166534)),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 20),
        Row(children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save Thresholds'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
            ),
            onPressed: () {
              setState(() => _thresholdSaved = true);
              Future.delayed(const Duration(seconds: 2),
                  () => setState(() => _thresholdSaved = false));
            },
          ),
          if (_thresholdSaved) ...[
            const SizedBox(width: 14),
            const Icon(Icons.check_circle,
                color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 6),
            const Text('Saved',
                style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600)),
          ],
        ]),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // SECTION 4 — Coordinator Accounts
  // ════════════════════════════════════════════════════════════════════
  Widget _buildCoordinatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                icon: Icons.manage_accounts,
                title: 'Coordinator Accounts',
                subtitle:
                    'Manage who has access to this admin dashboard',
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add Coordinator'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
              ),
              onPressed: _openAddCoordinatorDialog,
            ),
          ],
        ),
        const SizedBox(height: 28),

        _SettingsCard(
          child: Column(
            children: [
              // Table header
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: const [
                  Expanded(flex: 3, child: _ColHeader('Name')),
                  Expanded(flex: 3, child: _ColHeader('Email')),
                  Expanded(flex: 2, child: _ColHeader('Role')),
                  Expanded(flex: 1, child: _ColHeader('Status')),
                  SizedBox(width: 80, child: _ColHeader('Actions')),
                ]),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Rows
              ..._coordinators.asMap().entries.map((e) {
                final i = e.key;
                final coord = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Name + avatar
                      Expanded(
                        flex: 3,
                        child: Row(children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryColor
                                .withOpacity(coord.active ? 0.15 : 0.05),
                            child: Text(coord.name[0],
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: coord.active
                                        ? AppTheme.primaryColor
                                        : Colors.grey)),
                          ),
                          const SizedBox(width: 10),
                          Text(coord.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: coord.active
                                      ? Colors.black87
                                      : Colors.grey)),
                        ]),
                      ),

                      // Email
                      Expanded(
                        flex: 3,
                        child: Text(coord.email,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ),

                      // Role dropdown
                      Expanded(
                        flex: 2,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: coord.role,
                            isDense: true,
                            style: TextStyle(
                                fontSize: 12,
                                color: coord.active
                                    ? AppTheme.primaryColor
                                    : Colors.grey),
                            items: ['Super Admin', 'Coordinator', 'Viewer']
                                .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r,
                                        style: const TextStyle(
                                            fontSize: 12))))
                                .toList(),
                            onChanged: coord.active
                                ? (v) => setState(
                                    () => coord.role = v!)
                                : null,
                          ),
                        ),
                      ),

                      // Status badge
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: coord.active
                                ? const Color(0xFFDCFCE7)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                              coord.active ? 'Active' : 'Inactive',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: coord.active
                                      ? const Color(0xFF166534)
                                      : Colors.grey)),
                        ),
                      ),

                      // Actions
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Toggle active
                            Tooltip(
                              message: coord.active
                                  ? 'Deactivate'
                                  : 'Reactivate',
                              child: IconButton(
                                icon: Icon(
                                    coord.active
                                        ? Icons.person_off_outlined
                                        : Icons.person_outline,
                                    size: 18,
                                    color: coord.active
                                        ? Colors.orange
                                        : Colors.green),
                                onPressed: () => setState(
                                    () => coord.active = !coord.active),
                              ),
                            ),
                            // Delete
                            Tooltip(
                              message: 'Remove',
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                onPressed: () =>
                                    _confirmDeleteCoordinator(i),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 14),
        Text(
            '${_coordinators.where((c) => c.active).length} active · ${_coordinators.where((c) => !c.active).length} inactive',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _openAddCoordinatorDialog() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'Coordinator';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: const Text('Add Coordinator',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Field(
                    label: 'Full Name',
                    controller: nameCtrl,
                    icon: Icons.person),
                const SizedBox(height: 16),
                _Field(
                    label: 'Email Address',
                    controller: emailCtrl,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.badge, size: 18),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: ['Super Admin', 'Coordinator', 'Viewer']
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r,
                              style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) =>
                      setLocal(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                final name  = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                if (name.isEmpty || email.isEmpty) {
                  _showSnack('Please fill in all fields');
                  return;
                }
                setState(() => _coordinators.add(CoordinatorAccount(
                    name: name,
                    email: email,
                    role: selectedRole)));
                Navigator.pop(context);
                _showSnack('$name added as $selectedRole');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCoordinator(int index) {
    final coord = _coordinators[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Remove Coordinator?',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
            'Remove ${coord.name} (${coord.email}) from the dashboard?',
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
              setState(() => _coordinators.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2)));
}

// ════════════════════════════════════════════════════════════════════
// Reusable widgets
// ════════════════════════════════════════════════════════════════════

class _SectionNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SectionNavItem(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          color: active
              ? AppTheme.primaryColor.withOpacity(0.07)
              : Colors.transparent,
          child: Row(children: [
            Icon(icon,
                size: 18,
                color:
                    active ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: active
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: active
                        ? AppTheme.primaryColor
                        : Colors.grey.shade700)),
            if (active) ...[
              const Spacer(),
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ]),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader(
      {required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey)),
            ],
          ),
        ],
      );
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: child,
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  const _Field(
      {required this.label,
      required this.controller,
      required this.icon,
      this.keyboardType});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: AppTheme.primaryColor, width: 1.5)),
        ),
      );
}

class _ThresholdSlider extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color iconColor;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final void Function(double) onChanged;

  const _ThresholdSlider({
    required this.label,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${value.round()} $unit',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: iconColor)),
            ),
          ]),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: iconColor,
            inactiveColor: iconColor.withOpacity(0.15),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.round()}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
              Text('${max.round()}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      );
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5));
}