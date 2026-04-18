import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../core/routes.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.tasks),
          const Expanded(child: Center(child: Text('Tasks Screen — coming soon'))),
        ],
      ),
    );
  }
}
