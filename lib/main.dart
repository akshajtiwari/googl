import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const NGOAdminApp());
}

class NGOAdminApp extends StatelessWidget {
  const NGOAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Smart Resource Allocation',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            initialRoute: auth.loggedIn ? AppRoutes.dashboard : AppRoutes.login,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
