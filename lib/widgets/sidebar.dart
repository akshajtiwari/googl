import 'package:flutter/material.dart';
import '../core/routes.dart';

class Sidebar extends StatefulWidget {
  final String currentRoute;
  const Sidebar({super.key, required this.currentRoute});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF243F66),
            Color(0xFF1F3658),
          ],
        ),
      ),
      child: Column(
        children: [
          /// 🔥 TOP (LOGO + TOGGLE)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                if (!isCollapsed)
                  const Text(
                    "Helpora",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isCollapsed ? Icons.menu : Icons.menu_open,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                )
              ],
            ),
          ),

          /// PROFILE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Text("A", style: TextStyle(color: Colors.white)),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Admin",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                      Text("Administrator",
                          style:
                              TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  )
                ]
              ],
            ),
          ),

          const SizedBox(height: 20),

          Divider(color: Colors.white.withOpacity(0.08)),

          /// SECTION LABEL
          if (!isCollapsed)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Text(
                "MAIN",
                style: TextStyle(
                    color: Colors.white38, fontSize: 11, letterSpacing: 1),
              ),
            ),

          /// NAV ITEMS
          _NavItem(
            icon: Icons.report_problem,
            label: 'Dashboard',
            route: AppRoutes.dashboard,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),
          _NavItem(
            icon: Icons.assignment_ind,
            label: 'Assignments',
            route: AppRoutes.assignments,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),
          _NavItem(
            icon: Icons.map,
            label: 'Heatmap',
            route: '/heatmap',
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),
          _NavItem(
            icon: Icons.people,
            label: 'Volunteers',
            route: AppRoutes.volunteers,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),

          // _NavItem(
          //   icon: Icons.report_problem,
          //   label: 'Needs',
          //   route: AppRoutes.needs,
          //   current: widget.currentRoute,
          //   collapsed: isCollapsed,
          // ),

          _NavItem(
            icon: Icons.task,
            label: 'Tasks',
            route: AppRoutes.tasks,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),
          _NavItem(
            icon: Icons.analytics,
            label: 'Analytics',
            route: AppRoutes.analytics,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),

          _NavItem(
            icon: Icons.create,
            label: 'Create Form',
            route: AppRoutes.createForm,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),

          _NavItem(
            icon: Icons.chat,
            label: 'AI Chatbot',
            route: AppRoutes.aiChat,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),

          const Spacer(),

          /// FOOTER
          // ✅ WITH THIS
          _NavItem(
            icon: Icons.settings,
            label: 'Settings',
            route: AppRoutes.settings,
            current: widget.currentRoute,
            collapsed: isCollapsed,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: isCollapsed
                ? const SizedBox()
                : const Text("v1.0",
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// 🔥 NAV ITEM WITH HOVER + ACTIVE INDICATOR
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;
  final bool collapsed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
    required this.collapsed,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.current == widget.route;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.pushNamed(context, widget.route),
        onHover: (value) => setState(() => isHover = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.06)
                : isHover
                    ? Colors.white.withOpacity(0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              /// ACTIVE INDICATOR BAR
              if (isActive)
                Container(
                  width: 3,
                  height: 20,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else
                const SizedBox(width: 13),

              Icon(
                widget.icon,
                size: 20,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.65),
              ),

              if (!widget.collapsed) ...[
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.65),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );

    /// TOOLTIP (WHEN COLLAPSED)
    return widget.collapsed
        ? Tooltip(message: widget.label, child: content)
        : content;
  }
}
