import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/reward_model.dart';
import '../../models/user_model.dart';

class RewardProvider with ChangeNotifier {
  final Box<Reward> _rewardBox = Hive.box<Reward>('rewards');
  final Box<User> _userBox = Hive.box<User>('user_profile');

  List<Reward> get rewards => _rewardBox.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  void addReward(String title, int points) async {
    final reward = Reward(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      points: points,
      timestamp: DateTime.now(),
    );

    await _rewardBox.put(reward.id, reward);
    
    // Update user's total points
    final user = _userBox.get('current_user');
    if (user != null) {
      user.points += points;
      await user.save();
    }
    
    notifyListeners();
  }

  int get totalPoints {
    final user = _userBox.get('current_user');
    return user?.points ?? 0;
  }
}
