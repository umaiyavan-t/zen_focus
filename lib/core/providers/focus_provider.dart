import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_blocker/app_blocker.dart';
import '../../models/user_model.dart';
import '../../models/reward_model.dart';
// Note: BackgroundService removed

class FocusProvider with ChangeNotifier {
  int _secondsRemaining = 25 * 60;
  int _initialSeconds = 25 * 60;
  Timer? _timer;
  bool _isActive = false;
  bool _isPaused = false;
  List<String> _blockedApps = [];
  
  // App blocker state instance
  final _appBlocker = AppBlocker.instance;
  
  bool _isBlockedAlertVisible = false;

  int get secondsRemaining => _secondsRemaining;
  int get initialSeconds => _initialSeconds;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  bool get isBlockedAlertVisible => _isBlockedAlertVisible;
  List<String> get blockedApps => _blockedApps;
  String get status => _isActive ? (_isPaused ? 'PAUSED' : 'ACTIVE') : 'IDLE';

  FocusProvider() {
    _loadBlockedApps();
  }

  void _loadBlockedApps() {
    final box = Hive.box<String>('blocked_apps');
    _blockedApps = box.values.toList();
  }

  void setDuration(int minutes) {
    if (_isActive) return;
    _secondsRemaining = minutes * 60;
    _initialSeconds = _secondsRemaining;
    notifyListeners();
  }

  void toggleAppBlock(String packageName) async {
    final box = Hive.box<String>('blocked_apps');
    if (_blockedApps.contains(packageName)) {
      _blockedApps.remove(packageName);
      final key = box.keys.firstWhere((k) => box.get(k) == packageName);
      await box.delete(key);
    } else {
      _blockedApps.add(packageName);
      await box.add(packageName);
    }
    notifyListeners();
  }

  void startFocus() async {
    // Permission guard
    final status = await _appBlocker.checkPermission();
    
    if (status != BlockerPermissionStatus.granted) {
      debugPrint('Cannot start focus: Permissions missing');
      return;
    }

    _timer?.cancel();
    _isActive = true;
    _isPaused = false;
    
    // Start blocking via the new package
    await _appBlocker.blockApps(_blockedApps);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _secondsRemaining > 0) {
        _secondsRemaining--;
      } else if (_secondsRemaining <= 0) {
        stopFocus(completed: true);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseFocus() async {
    if (!_isActive) return;
    _isPaused = true;
    // Keep apps blocked even when paused, as per "stay focused" zen philosophy
    notifyListeners();
  }

  void resumeFocus() {
    if (!_isActive) return;
    _isPaused = false;
    notifyListeners();
  }

  void stopFocus({bool completed = false}) async {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _isPaused = false;
    _isBlockedAlertVisible = false;
    
    // Stop blocking via the new package (unblock all apps)
    await _appBlocker.unblockAll();
    
    if (completed) {
      final points = (_initialSeconds / 60).round();
      _addReward('Completed ${_initialSeconds ~/ 60}m Focus Session', points);
      _secondsRemaining = _initialSeconds;
    }
    notifyListeners();
  }

  void _addReward(String title, int points) async {
    // We add reward directly via Hive here for simplicity, 
    // but the RewardProvider will pick up the changes on notifyListeners if we are careful
    // Actually, it's better to let the UI call the provider if possible, 
    // but for background/timer completion, we'll do it here.
    final rewardBox = Hive.box<Reward>('rewards');
    final userBox = Hive.box<User>('user_profile');
    
    final reward = Reward(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      points: points,
      timestamp: DateTime.now(),
    );
    await rewardBox.put(reward.id, reward);

    final user = userBox.get('current_user');
    if (user != null) {
      user.points += points;
      await user.save();
    }
  }

  String formatTime() {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
