import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/focus_provider.dart';
import '../../core/providers/journal_provider.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final focusProvider = context.watch<FocusProvider>();
    final journalProvider = context.watch<JournalProvider>();
    
    final user = auth.currentUser;
    final points = user?.points ?? 0;
    final completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
    final totalTasks = taskProvider.tasks.length;
    final lastMood = journalProvider.entries.isNotEmpty ? journalProvider.entries.first.mood : '😐';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user?.username ?? 'Achiever'),
              const SizedBox(height: 32),
              _buildRewardCard(context, points),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Daily Insights'),
              const SizedBox(height: 16),
              _buildInsightsGrid(context, completedTasks, totalTasks, focusProvider.formatTime(), lastMood),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Quick Tips'),
              const SizedBox(height: 16),
              _buildTipCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'BE PRESENT, ${name.toUpperCase()}',
          style: GoogleFonts.outfit(
            fontSize: 12,
            letterSpacing: 4,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find your center.',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w200,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(BuildContext context, int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text(
            'ZEN POINTS',
            style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white24),
          ),
          const SizedBox(height: 16),
          Text(
            points.toString(),
            style: GoogleFonts.outfit(
              fontSize: 48,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Text(
              points > 500 ? 'FOCUS MASTER' : 'INITIATE',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 3,
        color: Colors.white24,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInsightsGrid(BuildContext context, int completed, int total, String focusTime, String mood) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(context, 'Tasks Done', '$completed/$total', Icons.done_all),
        _buildStatCard(context, 'Focus Time', focusTime, Icons.shutter_speed_outlined),
        _buildStatCard(context, 'Current Mood', mood, Icons.wb_sunny_outlined),
        _buildStatCard(context, 'Zen Rank', 'GOLD', Icons.architecture_outlined),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor.withOpacity(0.5), size: 20),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(),
            style: const TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.accentColor, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Stillness is where productivity begins.',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
