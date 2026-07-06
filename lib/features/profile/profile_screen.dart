import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../services/notification_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'reward_history_screen.dart';
import '../../core/providers/reward_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Box _settingsBox;
  bool _isWaterReminderEnabled = false;
  bool _isSleepReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _isWaterReminderEnabled = _settingsBox.get('water_reminder', defaultValue: false);
    _isSleepReminderEnabled = _settingsBox.get('sleep_reminder', defaultValue: false);
  }

  void _toggleWaterReminder(bool value) async {
    setState(() => _isWaterReminderEnabled = value);
    await _settingsBox.put('water_reminder', value);
    
    if (value) {
      await NotificationService.scheduleDailyReminder(101, 'Stay Hydrated 💧', 'Time for water.', 10, 0);
    } else {
      await NotificationService.cancelReminder(101);
    }
  }

  void _toggleSleepReminder(bool value) async {
    setState(() => _isSleepReminderEnabled = value);
    await _settingsBox.put('sleep_reminder', value);
    
    if (value) {
      await NotificationService.scheduleDailyReminder(102, 'Wind Down 🌙', 'Sleep is fuel.', 22, 0);
    } else {
      await NotificationService.cancelReminder(102);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rewardProvider = context.watch<RewardProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.surfaceColor,
              child: Text(
                user?.username.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w200, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user?.username ?? 'Seekeer',
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              '${rewardProvider.totalPoints} ZEN POINTS',
              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
            ),
            const SizedBox(height: 48),
            
            _buildProfileOption(
              context, 
              'Reward History', 
              FontAwesomeIcons.clockRotateLeft, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardHistoryScreen())),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Reminders'),
            _buildToggleOption(
              'Water Reminder',
              'Daily at 10:00 AM',
              FontAwesomeIcons.faucetDrip,
              _isWaterReminderEnabled,
              _toggleWaterReminder,
            ),
            _buildToggleOption(
              'Sleep Reminder',
              'Daily at 10:00 PM',
              FontAwesomeIcons.moon,
              _isSleepReminderEnabled,
              _toggleSleepReminder,
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Account'),
            _buildProfileOption(context, 'Help & Support', FontAwesomeIcons.circleQuestion, () {}),
            
            const SizedBox(height: 48),
            TextButton(
              onPressed: () => auth.logout(),
              child: const Text('LOGOUT', style: TextStyle(color: Colors.white10, letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildToggleOption(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white38)),
        trailing: Switch(
          value: value,
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.primaryColor, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
      ),
    );
  }
}
