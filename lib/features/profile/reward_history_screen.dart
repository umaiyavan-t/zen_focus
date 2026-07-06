import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/reward_provider.dart';
import 'package:intl/intl.dart';

class RewardHistoryScreen extends StatelessWidget {
  const RewardHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();
    final rewards = rewardProvider.rewards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REWARD HISTORY'),
      ),
      body: Column(
        children: [
          _buildTotalBanner(rewardProvider.totalPoints),
          Expanded(
            child: rewards.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      return _buildRewardTile(reward);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBanner(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: AppTheme.surfaceColor.withOpacity(0.5),
      child: Column(
        children: [
          Text(
            points.toString(),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w200,
              color: AppTheme.primaryColor,
              letterSpacing: 4,
            ),
          ),
          const Text(
            'TOTAL ZEN POINTS',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text(
            'Your zen journey begins here.',
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTile(dynamic reward) {
    final dateStr = DateFormat('MMM d, h:mm a').format(reward.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_outline, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '+${reward.points}',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
