import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../core/routes.dart';

class NeedsScreen extends StatelessWidget {
  const NeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.needs),
          const Expanded(child: Center(child: Text('Needs Screen — coming soon'))),
        ],
      ),
    );
  }
}
