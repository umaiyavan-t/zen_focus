import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:zen_focus/main.dart';
import 'package:zen_focus/core/providers/auth_provider.dart';
import 'package:zen_focus/core/providers/task_provider.dart';
import 'package:zen_focus/core/providers/focus_provider.dart';
import 'package:zen_focus/core/providers/journal_provider.dart';
import 'package:zen_focus/core/providers/reward_provider.dart';
import 'package:zen_focus/models/task_model.dart';
import 'package:zen_focus/models/journal_model.dart';
import 'package:zen_focus/models/user_model.dart';
import 'package:zen_focus/models/focus_session_model.dart';
import 'package:zen_focus/models/reward_model.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    // Create a temporary directory for Hive to write test DB files
    tempDir = await Directory.systemTemp.createTemp('zen_focus_test');
    Hive.init(tempDir.path);
    
    // Register adapters directly (so we don't call Hive.initFlutter() which relies on native path_provider)
    try {
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(JournalEntryAdapter());
      Hive.registerAdapter(UserAdapter());
      Hive.registerAdapter(FocusSessionAdapter());
      Hive.registerAdapter(RewardAdapter());
    } catch (_) {
      // Already registered
    }

    // Open Boxes
    await Hive.openBox('settings');
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<JournalEntry>('journal');
    await Hive.openBox<User>('user_profile');
    await Hive.openBox<FocusSession>('focus_history');
    await Hive.openBox<Reward>('rewards');
    await Hive.openBox<String>('blocked_apps');
  });

  tearDown(() async {
    // Clean up Hive boxes and close to avoid lock errors
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('App smoke test - opens login screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(
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

    // Give it time to load user state and settle
    await tester.pumpAndSettle();

    // Verify that the login screen title and prompt are rendered
    expect(find.text('Mindful.io'), findsOneWidget);
    expect(find.text('Unlock your potential.'), findsOneWidget);
    
    // Check for the username and password text fields (represented by hints)
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    
    // Check for the GET STARTED (login) button
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
