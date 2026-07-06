import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'features/navigation/navigation_screen.dart';
import 'features/auth/login_screen.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/focus_provider.dart';
import 'core/providers/journal_provider.dart';
import 'core/providers/reward_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  await HiveService.init();
  await NotificationService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
      ],
      child: const ProductivityApp(),
    ),
  );
}

class ProductivityApp extends StatelessWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Well-being',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const NavigationScreen() : const LoginScreen();
        },
      ),
    );
  }
}
