import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import '../../widgets/sidebar.dart';
import '../../widgets/heatmap_preview.dart';

// ─────────────────────────────────────────────────────────────
//  Data Models
// ─────────────────────────────────────────────────────────────

class _Notif {
  final String title, body, time;
  final IconData icon;
  final Color color;
  bool read;
  _Notif(this.title, this.body, this.time, this.icon, this.color,
      {this.read = false});
}

class _SearchResult {
  final String title, subtitle, route;
  final IconData icon;
  const _SearchResult(this.title, this.subtitle, this.route, this.icon);
}

// ─────────────────────────────────────────────────────────────
//  Dashboard Screen
// ─────────────────────────────────────────────────────────────

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: Row(
        children: [
          const Sidebar(currentRoute: '/dashboard'),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _AnimatedStatRow(),
                        const SizedBox(height: 24),
                        _ContentGrid(context: context),
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

// ─────────────────────────────────────────────────────────────
//  Top Bar — search + notifications + user menu
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatefulWidget {
  const _TopBar();

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final LayerLink _layerLink = LayerLink();

  String _searchQuery = '';

  /// 🔔 NOTIFICATIONS DATA
  final List<_Notif> _notifs = [
    _Notif("New Task Assigned", "Assigned to Zone 4", "2m",
        Icons.task_alt_rounded, Colors.blue),
    _Notif("Urgent Need", "Medical help needed", "10m",
        Icons.warning_amber_rounded, Colors.red),
    _Notif("Volunteer Joined", "New volunteer registered", "1h",
        Icons.people_alt_rounded, Colors.green),
  ];

  static const _allResults = [
    _SearchResult('Volunteers', 'Manage all volunteers', '/volunteers',
        Icons.people_alt_rounded),
    _SearchResult('Heatmap', 'View zone coverage heatmap', '/heatmap',
        Icons.map_rounded),
    _SearchResult('Assignments', 'Volunteer task assignments', '/assignments',
        Icons.assignment_rounded),
    _SearchResult('Needs', 'Community needs list', '/needs',
        Icons.report_problem_rounded),
    _SearchResult('Tasks', 'Active and pending tasks', '/tasks',
        Icons.task_alt_rounded),
  ];

  List<_SearchResult> get _filteredResults => _searchQuery.isEmpty
      ? []
      : _allResults
          .where((r) =>
              r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Text(
            'NGO Admin Dashboard',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),

          const Spacer(),

          /// 🔍 SEARCH
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 260,
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    onChanged: (v) => setState(() {
                      _searchQuery = v;
                    }),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, size: 17),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              if (_searchQuery.isNotEmpty)
                Positioned(
                  top: 48,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    child: Material(
                      elevation: 12,
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 260,
                        child: _SearchDropdown(
                          results: _filteredResults,
                          onSelect: (r) {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                            _searchFocus.unfocus();
                            Navigator.pushNamed(context, r.route);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          /// 🔔 NOTIFICATIONS (WORKING)
          GestureDetector(
            onTap: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "",
                barrierColor: Colors.black.withOpacity(0.1),
                pageBuilder: (_, __, ___) {
                  return _NotifPanel(
                    notifs: _notifs,
                    onMarkAllRead: () {
                      setState(() {
                        for (var n in _notifs) {
                          n.read = true;
                        }
                      });
                    },
                    onMarkRead: (n) {
                      setState(() {
                        n.read = true;
                      });
                    },
                  );
                },
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      size: 20, color: Color(0xFF64748B)),
                ),
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      '${_notifs.where((n) => !n.read).length}',
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          /// 👤 USER MENU (WORKING)
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "profile",
                child: Text("Profile"),
              ),
              const PopupMenuItem(
                value: "password",
                child: Text("Change Password"),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: "logout",
                child: Text("Logout"),
              ),
            ],
            onSelected: (value) {
              if (value == "logout") {
                // TODO: logout logic
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('A',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────
//  Search Dropdown
// ─────────────────────────────────────────────────────────────

class _SearchDropdown extends StatelessWidget {
  final List<_SearchResult> results;
  final void Function(_SearchResult) onSelect;
  const _SearchDropdown({required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(14),
      shadowColor: Colors.black.withOpacity(0.12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (_, i) {
            final r = results[i];
            return InkWell(
              onTap: () => onSelect(r),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(r.icon,
                          size: 16, color: const Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A202C))),
                          Text(r.subtitle,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Notification Panel Dialog
// ─────────────────────────────────────────────────────────────

class _NotifPanel extends StatefulWidget {
  final List<_Notif> notifs;
  final VoidCallback onMarkAllRead;
  final void Function(_Notif) onMarkRead;
  const _NotifPanel(
      {required this.notifs,
      required this.onMarkAllRead,
      required this.onMarkRead});

  @override
  State<_NotifPanel> createState() => _NotifPanelState();
}

class _NotifPanelState extends State<_NotifPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0.05, -0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.topRight,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Container(
                  width: 380,
                  margin: const EdgeInsets.only(top: 68, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                        child: Row(
                          children: [
                            const Text('Notifications',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A202C))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${widget.notifs.where((n) => !n.read).length}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: widget.onMarkAllRead,
                              child: const Text('Mark all read',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      // List
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 360),
                        child: StatefulBuilder(builder: (ctx, setS) {
                          return ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: widget.notifs.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Color(0xFFF8FAFC)),
                            itemBuilder: (_, i) {
                              final n = widget.notifs[i];
                              return InkWell(
                                onTap: () {
                                  widget.onMarkRead(n);
                                  setS(() {});
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  color: n.read
                                      ? Colors.transparent
                                      : n.color.withOpacity(0.04),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: n.color.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(n.icon,
                                            size: 17, color: n.color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                child: Text(n.title,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: n.read
                                                            ? FontWeight.w400
                                                            : FontWeight.w600,
                                                        color: const Color(
                                                            0xFF1A202C))),
                                              ),
                                              if (!n.read)
                                                Container(
                                                  width: 7,
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                      color: n.color,
                                                      shape:
                                                          BoxShape.circle),
                                                ),
                                            ]),
                                            const SizedBox(height: 3),
                                            Text(n.body,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Color(0xFF64748B))),
                                            const SizedBox(height: 4),
                                            Text(n.time,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Color(0xFF94A3B8))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      const Divider(height: 1),
                      // Footer
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text('View all notifications',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Animated Stat Row  (unchanged from before)
// ─────────────────────────────────────────────────────────────

class _StatMeta {
  final String value, label, route;
  final IconData icon;
  final Color color;

  const _StatMeta(
    this.value,
    this.label,
    this.icon,
    this.color,
    this.route,
  );
}

class _AnimatedStatRow extends StatefulWidget {
  const _AnimatedStatRow();

  @override
  State<_AnimatedStatRow> createState() => _AnimatedStatRowState();
}

class _AnimatedStatRowState extends State<_AnimatedStatRow>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

static const _cards = [
  _StatMeta('142', 'Total Volunteers', Icons.people_alt_rounded,
      Color(0xFF3B82F6), '/volunteers'),

  _StatMeta('38', 'Active Tasks', Icons.task_alt_rounded,
      Color(0xFF10B981), '/tasks'),

  _StatMeta('21', 'Pending Needs', Icons.warning_amber_rounded,
      Color(0xFFF59E0B), '/needs'),

  _StatMeta('74%', 'Zone Coverage', Icons.public_rounded,
      Color(0xFF06B6D4), '/heatmap'),
];

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        4,
        (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 600)));
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _ctrls
        .map((c) => Tween<Offset>(
                begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
                CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: 120 * i),
          () { if (mounted) _ctrls[i].forward(); });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < 3 ? 16 : 0),
          child: FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: _StatCard(meta: _cards[i]),
            ),
          ),
        ),
      )),
    );
  }
}

class _StatCard extends StatefulWidget {
  final _StatMeta meta;
  const _StatCard({required this.meta});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.meta;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_hovered ? 1.025 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [m.color, m.color.withOpacity(0.72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: m.color.withOpacity(_hovered ? 0.45 : 0.28),
              blurRadius: _hovered ? 28 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.value,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0)),
                      const SizedBox(height: 5),
                      Text(m.label,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.88))),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, widget.meta.route);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) => Transform.scale(
                    scale: _pulse.value,
                    alignment: Alignment.bottomRight,
                    child: child,
                  ),
                  child: Icon(m.icon,
                      size: 56,
                      color: Colors.white.withOpacity(0.15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Content Grid, Panel Card, Activity Row, Alert Card,
//  Animated Charts Card  — all unchanged from previous message,
//  paste them here exactly as before
// ─────────────────────────────────────────────────────────────

class _ContentGrid extends StatelessWidget {
  final BuildContext context;
  const _ContentGrid({required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _PanelCard(
                title: 'Recent activity',
                actionLabel: 'View all',
                child: const Column(children: [
                  _ActivityRow(
                    icon: Icons.notifications_rounded,
                    iconColor: Color(0xFF10B981),
                    iconBg: Color(0xFFD1FAE5),
                    title: 'John Doe added a new gallery image!',
                    subtitle: '2 minute ago',
                    time: '2m',
                  ),
                  _ActivityRow(
                    icon: Icons.description_rounded,
                    iconColor: Color(0xFF3B82F6),
                    iconBg: Color(0xFFDBEAFE),
                    title:
                        'Field report submitted from Zone 4B by Meera S.',
                    subtitle: '15 mins ago',
                    time: '15m',
                  ),
                  _ActivityRow(
                    icon: Icons.check_circle_rounded,
                    iconColor: Color(0xFF10B981),
                    iconBg: Color(0xFFD1FAE5),
                    title:
                        'Susan Lee completed — Food distribution, Zone 2',
                    subtitle: '1 hour ago',
                    time: '1h',
                    isLast: true,
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              _PanelCard(
                title: 'Top Referrals',
                actionLabel: 'View all',
                child: const Column(children: [
                  _ActivityRow(
                    icon: Icons.notifications_rounded,
                    iconColor: Color(0xFF10B981),
                    iconBg: Color(0xFFD1FAE5),
                    title: 'John Doe added a new gallery image!',
                    subtitle: '2 minutes ago',
                    time: '2 min',
                  ),
                  _ActivityRow(
                    icon: Icons.check_circle_rounded,
                    iconColor: Color(0xFF10B981),
                    iconBg: Color(0xFFD1FAE5),
                    title:
                        'Field report submid from Zone 4B by Meera S.',
                    subtitle: '1 hour ago',
                    time: '15m',
                    isLast: true,
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              const _AnimatedChartsCard(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _PanelCard(
                title: 'Heatmap',
                actionLabel: 'View all zones',
                onAction: () =>
                    Navigator.pushNamed(context, '/heatmap'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                      height: 240, child: HeatmapPreview()),
                ),
              ),
              const SizedBox(height: 20),
              _PanelCard(
                title: 'Alerts',
                actionLabel: 'View all',
                child: const Column(children: [
                  _AlertCard(
                    zone: 'Zone 4 — Medical, critical',
                    subtitle:
                        "Unmet for 6+ hours. No volunteer'ly needeed.",
                    color: Color(0xFFEF4444),
                    btnLabel: 'Assign now',
                    isCritical: true,
                  ),
                  SizedBox(height: 10),
                  _AlertCard(
                    zone: 'Zone 2 — Low coverage',
                    subtitle:
                        '8 active tasks. Minimum threshol lis 40%, 9%.',
                    color: Color(0xFFF59E0B),
                    btnLabel: 'View zone',
                    isCritical: false,
                  ),
                  SizedBox(height: 10),
                  _AlertCard(
                    zone: 'Zone 6 — Shelter shortage',
                    subtitle: '32 needs open. New shelter needed.',
                    color: Color(0xFF3B82F6),
                    btnLabel: 'View zone',
                    isCritical: false,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title, actionLabel;
  final Widget child;
  final VoidCallback? onAction;
  const _PanelCard(
      {required this.title,
      required this.actionLabel,
      required this.child,
      this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C))),
              const Spacer(),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Text(actionLabel,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2563EB))),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded,
                        size: 15, color: Color(0xFF2563EB)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, subtitle, time;
  final bool isLast;
  const _ActivityRow(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.title,
      required this.subtitle,
      required this.time,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A202C))),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8))),
            ]),
          ),
          const SizedBox(width: 8),
          Text(time,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ]),
      ),
      if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
    ]);
  }
}

class _AlertCard extends StatelessWidget {
  final String zone, subtitle, btnLabel;
  final Color color;
  final bool isCritical;
  const _AlertCard(
      {required this.zone,
      required this.subtitle,
      required this.color,
      required this.btnLabel,
      required this.isCritical});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(zone,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(height: 4),
        isCritical
            ? RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                  children: [
                    const TextSpan(text: 'Unmet for '),
                    TextSpan(
                        text: '6+ hours',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: color)),
                    const TextSpan(
                        text: ". No volunteer'ly needeed."),
                  ],
                ),
              )
            : Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(20)),
          child: Text(btnLabel,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _AnimatedChartsCard extends StatefulWidget {
  const _AnimatedChartsCard();

  @override
  State<_AnimatedChartsCard> createState() => _AnimatedChartsCardState();
}

class _AnimatedChartsCardState extends State<_AnimatedChartsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pieCtrl;
  late final Animation<double> _pieAnim;
  int _touchedIndex = -1;

  static const _sections = [
    (value: 32.0, color: Color(0xFF3B82F6), label: 'www.facebook.com'),
    (value: 22.0, color: Color(0xFF10B981), label: 'google.com'),
    (value: 20.0, color: Color(0xFFF59E0B), label: 'instagram.com'),
    (value: 26.0, color: Color(0xFFEF4444), label: 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _pieCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pieAnim =
        CurvedAnimation(parent: _pieCtrl, curve: Curves.easeOutCubic);
    _pieCtrl.forward();
  }

  @override
  void dispose() {
    _pieCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text('Top Referrals',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C))),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: AnimatedBuilder(
                animation: _pieAnim,
                builder: (_, __) => PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, resp) => setState(() {
                        _touchedIndex = resp?.touchedSection
                                ?.touchedSectionIndex ??
                            -1;
                      }),
                    ),
                    startDegreeOffset:
                        -90 + (360 * (1 - _pieAnim.value)),
                    sectionsSpace: 2,
                    centerSpaceRadius: 32,
                    sections: List.generate(_sections.length, (i) {
                      final s = _sections[i];
                      final touched = i == _touchedIndex;
                      return PieChartSectionData(
                        value: s.value * _pieAnim.value,
                        color: s.color,
                        radius: touched ? 58 : 48,
                        title: '${s.value.toInt()}%',
                        titleStyle: TextStyle(
                            fontSize: touched ? 13 : 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      );
                    }),
                  ),
                  swapAnimationDuration:
                      const Duration(milliseconds: 300),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text('Most Used OS',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C))),
            const SizedBox(height: 20),
            ..._sections.map((s) => _AnimatedLegendRow(
                color: s.color,
                label: s.label,
                percent: s.value / 100)),
          ]),
        ),
      ]),
    );
  }
}

class _AnimatedLegendRow extends StatefulWidget {
  final Color color;
  final String label;
  final double percent;
  const _AnimatedLegendRow(
      {required this.color, required this.label, required this.percent});

  @override
  State<_AnimatedLegendRow> createState() => _AnimatedLegendRowState();
}

class _AnimatedLegendRowState extends State<_AnimatedLegendRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 400),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: widget.color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(widget.label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF475569))),
          ),
          Text('${(widget.percent * 100).toInt()}%',
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => LinearProgressIndicator(
              value: widget.percent * _anim.value,
              minHeight: 5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(widget.color),
            ),
          ),
        ),
      ]),
    );
  }
}