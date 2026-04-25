import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/routes.dart';
import '../../models/ui_models.dart';
import '../../services/dashboard_service.dart';
import '/widgets/heatmap_preview.dart';

// ─────────────────────────────────────────────────────────────
//  Breadcrumbs & Stats
// ─────────────────────────────────────────────────────────────
class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          const Text('Home',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFFCBD5E1)),
          ),
          const Text('Dashboard',
              style: TextStyle(fontSize: 11, color: Color(0xFF1A202C), fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            "Today, ${DateTime.now().day} ${_month(DateTime.now().month)}",
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          )
        ],
      ),
    );
  }

  String _month(int m) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];
}

class AnimatedStatRow extends StatelessWidget {
  const AnimatedStatRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600 && !isDesktop;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: DashboardService.stats.map((stat) {
            return SizedBox(
              width: isDesktop
                  ? (constraints.maxWidth - (16 * 3)) / 4
                  : isTablet
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth,
              child: StatCard(meta: stat),
            );
          }).toList(),
        );
      },
    );
  }
}

class StatCard extends StatefulWidget {
  final StatMeta meta;
  const StatCard({super.key, required this.meta});

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.meta;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, widget.meta.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [m.color, m.color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: m.color.withOpacity(_hovered ? 0.4 : 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 8),
                      Text(m.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0)),
                    ],
                  ),
                ),
                Icon(m.icon, size: 48, color: Colors.white.withOpacity(0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Content Grid & Columns
// ─────────────────────────────────────────────────────────────
class ContentGrid extends StatelessWidget {
  const ContentGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return const Column(
            children: [
              _LeftColItems(),
              SizedBox(height: 24),
              _RightColItems(),
            ],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 45, child: _LeftColItems()),
            SizedBox(width: 24),
            Expanded(flex: 55, child: _RightColItems()),
          ],
        );
      },
    );
  }
}

class _LeftColItems extends StatelessWidget {
  const _LeftColItems();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PanelCard(
          title: 'Recent activity',
          actionLabel: 'View all',
          child: Column(children: [
            ActivityRow(icon: Icons.notifications_rounded, iconColor: Color(0xFF10B981), iconBg: Color(0xFFD1FAE5), title: 'John Doe added a new gallery image!', subtitle: '2 minute ago', time: '2m'),
            ActivityRow(icon: Icons.description_rounded, iconColor: Color(0xFF3B82F6), iconBg: Color(0xFFDBEAFE), title: 'Field report submitted from Zone 4B by Meera S.', subtitle: '15 mins ago', time: '15m'),
            ActivityRow(icon: Icons.check_circle_rounded, iconColor: Color(0xFF10B981), iconBg: Color(0xFFD1FAE5), title: 'Susan Lee completed — Food distribution, Zone 2', subtitle: '1 hour ago', time: '1h', isLast: true),
          ]),
        ),
        SizedBox(height: 24),
        AnimatedChartsCard(),
      ],
    );
  }
}

class _RightColItems extends StatelessWidget {
  const _RightColItems();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelCard(
          title: 'Heatmap',
          actionLabel: 'View all zones',
          onAction: () => Navigator.pushNamed(context, AppRoutes.heatmap),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const SizedBox(height: 240, child: HeatmapPreview()),
          ),
        ),
        const SizedBox(height: 24),
        PanelCard(
          title: 'Alerts',
          actionLabel: 'View all alerts',
          child: Column(children: [
            AlertCard(
              zone: 'Zone 4 — Medical, critical',
              subtitle: "Unmet for 6+ hours.",
              color: const Color(0xFFD93025), // Google Red
              btnLabel: 'Assign now',
              isCritical: true,
              onAction: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assigning volunteer...'))),
            ),
            const SizedBox(height: 16),
            AlertCard(
              zone: 'Zone 2 — Low coverage',
              subtitle: '8 active tasks. Minimum threshold is 40%.',
              color: const Color(0xFFF29900), // Google Yellow
              btnLabel: 'View zone',
              isCritical: false,
              onAction: () => Navigator.pushNamed(context, AppRoutes.heatmap),
            ),
            const SizedBox(height: 16),
            AlertCard(
              zone: 'Zone 6 — Shelter shortage',
              subtitle: '32 needs open. New shelter needed.',
              color: const Color(0xFF1A73E8), // Google Blue
              btnLabel: 'View zone',
              isCritical: false,
              onAction: () => Navigator.pushNamed(context, AppRoutes.needs),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Google M3 Style Custom Buttons (NEW)
// ─────────────────────────────────────────────────────────────

/// Sleek, pill-shaped text button with animated arrow sliding
class _GoogleTextButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _GoogleTextButton({required this.label, this.onTap});

  @override
  State<_GoogleTextButton> createState() => _GoogleTextButtonState();
}

class _GoogleTextButtonState extends State<_GoogleTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap ?? () {},
        onHover: (hovering) => setState(() => _isHovered = hovering),
        borderRadius: BorderRadius.circular(100),
        hoverColor: const Color(0xFFE8F0FE), // Light Google Blue
        splashColor: const Color(0xFFD2E3FC).withOpacity(0.5),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: _isHovered ? const Color(0xFF174EA6) : const Color(0xFF1A73E8),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                // The magic micro-interaction: arrow shifts right on hover
                transform: Matrix4.translationValues(_isHovered ? 4.0 : 0.0, 0.0, 0.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _isHovered ? const Color(0xFF174EA6) : const Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Solid pill button with dynamic glowing elevation on hover
class _GooglePrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GooglePrimaryButton({required this.label, required this.color, required this.onTap});

  Color _lighten(Color c, [double amount = 0.08]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return _lighten(color);
          return color;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return 6.0;
          if (states.contains(WidgetState.pressed)) return 2.0;
          return 0.0; // Flat by default
        }),
        shadowColor: WidgetStateProperty.all(color.withOpacity(0.5)), // Colored shadow glow
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared UI Components (Updated with Google Buttons)
// ─────────────────────────────────────────────────────────────
class PanelCard extends StatelessWidget {
  final String title, actionLabel;
  final Widget child;
  final VoidCallback? onAction;
  const PanelCard({super.key, required this.title, required this.actionLabel, required this.child, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.04, color: Color(0xFF1A202C))),
              const Spacer(),
              // INTEGRATED GOOGLE TEXT BUTTON HERE
              if (actionLabel.isNotEmpty) 
                _GoogleTextButton(label: actionLabel, onTap: onAction),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, subtitle, time;
  final bool isLast;
  const ActivityRow({super.key, required this.icon, required this.iconColor, required this.iconBg, required this.title, required this.subtitle, required this.time, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF1A202C))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ]),
          ),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ]),
      ),
      if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
    ]);
  }
}

class AlertCard extends StatelessWidget {
  final String zone, subtitle, btnLabel;
  final Color color;
  final bool isCritical;
  final VoidCallback onAction;
  const AlertCard({super.key, required this.zone, required this.subtitle, required this.color, required this.btnLabel, required this.isCritical, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(zone, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        const SizedBox(height: 16),
        // INTEGRATED GOOGLE PRIMARY BUTTON HERE
        _GooglePrimaryButton(label: btnLabel, color: color, onTap: onAction),
      ]),
    );
  }
}

class AnimatedChartsCard extends StatelessWidget {
  const AnimatedChartsCard({super.key});

  static const _sections = [
    (value: 32.0, color: Color(0xFF3B82F6), label: 'Facebook'),
    (value: 22.0, color: Color(0xFF10B981), label: 'Google'),
    (value: 20.0, color: Color(0xFFF59E0B), label: 'Instagram'),
    (value: 26.0, color: Color(0xFFEF4444), label: 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Referrals Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.04, color: Color(0xFF1A202C))),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(_sections.length, (i) {
                      final s = _sections[i];
                      return PieChartSectionData(value: s.value, color: s.color, radius: 20, showTitle: false);
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: _sections
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(s.label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                                Text('${s.value.toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A202C))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}