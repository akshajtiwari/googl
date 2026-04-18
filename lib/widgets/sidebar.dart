import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/routes.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;
  const Sidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'NexusAid',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white24),
          _NavItem(icon: Icons.dashboard,      label: 'Dashboard',  route: AppRoutes.dashboard,  current: currentRoute),
          _NavItem(icon: Icons.map,            label: 'Heatmap',    route: '/heatmap',           current: currentRoute),
          _NavItem(icon: Icons.people,         label: 'Volunteers', route: AppRoutes.volunteers, current: currentRoute),
          _NavItem(icon: Icons.report_problem, label: 'Needs',      route: AppRoutes.needs,      current: currentRoute),
          _NavItem(icon: Icons.task,           label: 'Tasks',      route: AppRoutes.tasks,      current: currentRoute),
          _NavItem(icon: Icons.analytics,      label: 'Analytics',  route: '/analytics',         current: currentRoute),
          _NavItem(icon: Icons.settings,       label: 'Settings',   route: '/settings',          current: currentRoute),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        color: isActive ? Colors.white12 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white60, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white60,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
