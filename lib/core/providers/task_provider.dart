import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/task_model.dart';
import '../../models/reward_model.dart';
import '../../models/user_model.dart';

class TaskProvider with ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  
  List<Task> get tasks => _taskBox.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void addTask(String title) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    await _taskBox.put(task.id, task);
    notifyListeners();
  }

  void toggleTaskStatus(String id) async {
    final task = _taskBox.get(id);
    if (task != null) {
      bool wasCompleted = task.isCompleted;
      task.isCompleted = !task.isCompleted;
      await task.save();
      
      if (!wasCompleted && task.isCompleted) {
        _logTaskReward(task.title);
      }
      
      notifyListeners();
    }
  }

  void _logTaskReward(String title) async {
    final rewardBox = Hive.box<Reward>('rewards');
    final userBox = Hive.box<User>('user_profile');
    
    final reward = Reward(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Completed Task: $title',
      points: 5, // 5 points per task
      timestamp: DateTime.now(),
    );
    await rewardBox.put(reward.id, reward);

    final user = userBox.get('current_user');
    if (user != null) {
      user.points += 5;
      await user.save();
    }
  }

  void deleteTask(String id) async {
    await _taskBox.delete(id);
    notifyListeners();
  }
}
