import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/journal_model.dart';
import '../models/user_model.dart';
import '../models/focus_session_model.dart';
import '../models/reward_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(FocusSessionAdapter());
    Hive.registerAdapter(RewardAdapter());

    // Open Boxes
    await Hive.openBox('settings');
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<JournalEntry>('journal');
    await Hive.openBox<User>('user_profile');
    await Hive.openBox<FocusSession>('focus_history');
    await Hive.openBox<Reward>('rewards');
    await Hive.openBox<String>('blocked_apps'); // Box for app blocker
  }
}
