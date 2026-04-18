import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../core/routes.dart';

class VolunteersScreen extends StatelessWidget {
  const VolunteersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.volunteers),
          const Expanded(child: Center(child: Text('Volunteers Screen — coming soon'))),
        ],
      ),
    );
  }
}
