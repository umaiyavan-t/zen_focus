import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/focus_provider.dart';

class AppSelectionScreen extends StatelessWidget {
  const AppSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Distractions'),
      ),
      body: FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(excludeSystemApps: true, withIcon: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No apps found'));
          }

          final apps = snapshot.data!;
          // Remove this app from the list
          apps.removeWhere((app) => app.packageName == 'com.example.productivity_app');

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _buildAppItem(context, app);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppItem(BuildContext context, AppInfo app) {
    final focusProvider = context.watch<FocusProvider>();
    final isBlocked = focusProvider.blockedApps.contains(app.packageName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: app.icon != null 
            ? Image.memory(app.icon!, width: 40) 
            : const Icon(Icons.android, color: Colors.white24),
        title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(app.packageName, style: const TextStyle(fontSize: 10, color: Colors.white24)),
        trailing: Switch(
          value: isBlocked,
          activeColor: AppTheme.primaryColor,
          onChanged: (value) => focusProvider.toggleAppBlock(app.packageName),
        ),
      ),
    );
  }
}
