import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/dashboard_widgets.dart';
import 'create_form_tab.dart';
import 'ai_chatbot_tab.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Row(
          children: [
            const Sidebar(currentRoute: AppRoutes.dashboard),
            Expanded(
              child: Column(
                children: [
                  const TopBar(),
                  const TabBar(
                    labelColor: Colors.black,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Create Form'),
                      Tab(text: 'AI Chatbot'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Overview tab: existing content
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1440),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedStatRow(),
                                  SizedBox(height: 24),
                                  ContentGrid(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Create Form tab
                        const CreateFormTab(),
                        // AI Chatbot tab
                        const AiChatbotTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
