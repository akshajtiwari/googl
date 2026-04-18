import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/stat_card.dart';
import '../../core/routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.dashboard),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dashboard',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C))),
                  const SizedBox(height: 8),
                  const Text("Welcome back. Here's what's happening today.",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    childAspectRatio: 2.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      StatCard(title: 'Total Volunteers', value: '142', icon: Icons.people,         color: Color(0xFF2E5F8A)),
                      StatCard(title: 'Active Tasks',     value: '38',  icon: Icons.task_alt,       color: Color(0xFF27AE60)),
                      StatCard(title: 'Pending Needs',    value: '21',  icon: Icons.report_problem, color: Color(0xFFE67E22)),
                      StatCard(title: 'Coverage',         value: '74%', icon: Icons.location_on,    color: Color(0xFF8E44AD)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Recent Activity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final items = [
                          ('Riya Sharma assigned to Task #34', '2 mins ago',  Icons.person_add),
                          ('New field report from Zone 4B',    '15 mins ago', Icons.upload_file),
                          ('Task #29 marked completed',        '1 hr ago',    Icons.check_circle),
                          ('New need flagged: Medical — Zone 7','2 hrs ago',  Icons.warning),
                        ];
                        return ListTile(
                          leading: Icon(items[index].$3, color: const Color(0xFF2E5F8A)),
                          title: Text(items[index].$1),
                          trailing: Text(items[index].$2,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
