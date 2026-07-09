import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/task_model.dart';
import '../../models/reward_model.dart';
import '../../models/user_model.dart';

class TaskProvider with ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  // ── Static helpers ──────────────────────────────────────────────────────────

  /// Converts a DateTime to a "yyyy-MM-dd" key for Hive & streak lookups.
  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Strips the time component from a DateTime.
  static DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  // ── All-tasks getter (ALL tab) ──────────────────────────────────────────────

  List<Task> get tasks =>
      _taskBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // ── Planner queries ─────────────────────────────────────────────────────────

  /// Tasks visible in the daily planner for [date]:
  ///   • Recurring tasks (appear every day)
  ///   • Scheduled tasks whose scheduledDate == [date]
  /// Sorted: timed tasks first (by slot), then by priority desc.
  /// Tasks visible in the daily planner for [date]:
  ///   • Recurring tasks (appear every day)
  ///   • Scheduled tasks whose scheduledDate == [date] AND isWeekly == false
  /// Sorted: timed tasks first (by slot), then by priority desc.
  List<Task> getTasksForDate(DateTime date) {
    final nd = normalizeDate(date);
    return _taskBox.values.where((t) {
      if (t.isWeekly) return false;
      if (t.isRecurring) return true;
      if (t.scheduledDate == null) return false;
      return normalizeDate(t.scheduledDate!) == nd;
    }).toList()
      ..sort((a, b) {
        if (a.timeSlot != null && b.timeSlot != null) {
          return a.timeSlot!.compareTo(b.timeSlot!);
        }
        if (a.timeSlot != null) return -1;
        if (b.timeSlot != null) return 1;
        return b.priority.compareTo(a.priority);
      });
  }

  /// Weekly intentions/tasks for the week containing [date]:
  List<Task> getWeeklyTasksForDate(DateTime date) {
    final nd = normalizeDate(date);
    final weekday = nd.weekday;
    final monday = nd.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    return _taskBox.values.where((t) {
      if (!t.isWeekly) return false;
      if (t.scheduledDate == null) return false;
      final taskDate = normalizeDate(t.scheduledDate!);
      return !taskDate.isBefore(monday) && !taskDate.isAfter(sunday);
    }).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Whether [task] is completed on [date].
  /// Recurring → checks completedDates list.
  /// Non-recurring → uses the simple isCompleted flag.
  bool isTaskCompletedOnDate(Task task, DateTime date) {
    if (task.isRecurring) return task.completedDates.contains(dateKey(date));
    return task.isCompleted;
  }

  /// 0.0–1.0 completion rate for [date] (for heatmap coloring, based on daily tasks).
  double getCompletionRateForDate(DateTime date) {
    final dayTasks = getTasksForDate(date);
    if (dayTasks.isEmpty) return 0.0;
    final done = dayTasks.where((t) => isTaskCompletedOnDate(t, date)).length;
    return done / dayTasks.length;
  }

  int getCompletedCountForDate(DateTime date) =>
      getTasksForDate(date).where((t) => isTaskCompletedOnDate(t, date)).length;

  int getTotalCountForDate(DateTime date) => getTasksForDate(date).length;

  // ── Streak ──────────────────────────────────────────────────────────────────

  /// Consecutive days (going back from today) where ≥ 1 task was completed.
  /// Days with NO tasks at all are skipped — they don't break or build the streak.
  int getStreakCount() {
    int streak = 0;
    final today = normalizeDate(DateTime.now());

    for (int i = 0; i < 90; i++) {
      final day = today.subtract(Duration(days: i));
      final dayTasks = getTasksForDate(day);
      if (dayTasks.isEmpty) continue; // no tasks scheduled → skip this day
      final hasCompletion = dayTasks.any((t) => isTaskCompletedOnDate(t, day));
      if (hasCompletion) {
        streak++;
      } else {
        break; // had tasks but completed none → streak broken
      }
    }

    return streak;
  }

  // ── Heatmap data ────────────────────────────────────────────────────────────

  /// Returns [weeks] × 7 entries of (date, completionRate) starting from the
  /// Monday that is [weeks-1] weeks before the current week's Monday.
  /// Entries after today are excluded.
  List<MapEntry<DateTime, double>> getHeatmapData({int weeks = 10}) {
    final result = <MapEntry<DateTime, double>>[];
    final today = normalizeDate(DateTime.now());

    // Find the Monday of the current week
    final todayWeekday = today.weekday; // 1=Mon … 7=Sun
    DateTime weekStart = today.subtract(Duration(days: todayWeekday - 1));

    // Go back (weeks-1) more weeks
    weekStart = weekStart.subtract(Duration(days: (weeks - 1) * 7));

    for (int w = 0; w < weeks; w++) {
      for (int d = 0; d < 7; d++) {
        final day = weekStart.add(Duration(days: w * 7 + d));
        if (day.isAfter(today)) return result; // stop at today
        result.add(MapEntry(day, getCompletionRateForDate(day)));
      }
    }
    return result;
  }

  // ── Weekly stats ────────────────────────────────────────────────────────────

  Map<String, dynamic> getWeeklyStats(DateTime weekStart) {
    int totalCompleted = 0;
    int totalTasks = 0;
    int bestDayCount = 0;
    String bestDayName = '—';
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // 1. Calculate daily tasks stats for the week
    for (int d = 0; d < 7; d++) {
      final day = weekStart.add(Duration(days: d));
      final done = getCompletedCountForDate(day);
      final total = getTotalCountForDate(day);
      totalCompleted += done;
      totalTasks += total;
      if (done > bestDayCount) {
        bestDayCount = done;
        bestDayName = dayNames[d];
      }
    }

    // 2. Add weekly tasks stats for the week
    final weeklyTasks = getWeeklyTasksForDate(weekStart);
    final weeklyDone = weeklyTasks.where((t) => t.isCompleted).length;
    totalCompleted += weeklyDone;
    totalTasks += weeklyTasks.length;

    return {
      'totalCompleted': totalCompleted,
      'totalTasks': totalTasks,
      'rate': totalTasks == 0 ? 0.0 : totalCompleted / totalTasks,
      'bestDay': bestDayName,
    };
  }

  // ── Mutations ───────────────────────────────────────────────────────────────

  /// Add a simple unscheduled task (ALL tab — backward compatible).
  void addTask(String title) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    await _taskBox.put(task.id, task);
    notifyListeners();
  }

  /// Add a fully configured planned task (Daily / Weekly planner).
  void addPlannedTask({
    required String title,
    DateTime? scheduledDate,
    int priority = 1,
    String? timeSlot,
    bool isRecurring = false,
    int? estimatedMinutes,
    bool isMIT = false,
    bool isWeekly = false,
  }) async {
    // Enforce single MIT per day — unset any existing MIT for the same date
    if (isMIT && !isWeekly) {
      final refDate = scheduledDate ?? normalizeDate(DateTime.now());
      final existing = getTasksForDate(refDate).where((t) => t.isMIT);
      for (final t in existing) {
        t.isMIT = false;
        await t.save();
      }
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      scheduledDate: isRecurring ? null : scheduledDate,
      priority: priority,
      timeSlot: isWeekly ? null : timeSlot, // Weekly tasks don't have slots
      isRecurring: isRecurring,
      estimatedMinutes: estimatedMinutes,
      isMIT: isWeekly ? false : isMIT, // Weekly tasks don't have MIT
      isWeekly: isWeekly,
    );
    await _taskBox.put(task.id, task);
    notifyListeners();
  }

  /// Toggle completion.
  /// For recurring tasks, pass [date] to record completion for that specific day.
  /// For non-recurring tasks, toggles isCompleted (date ignored).
  void toggleTaskStatus(String id, {DateTime? date}) async {
    final task = _taskBox.get(id);
    if (task == null) return;

    if (task.isRecurring) {
      final effectiveDate = date != null ? normalizeDate(date) : normalizeDate(DateTime.now());
      final key = dateKey(effectiveDate);
      final wasCompleted = task.completedDates.contains(key);
      if (wasCompleted) {
        task.completedDates.remove(key);
      } else {
        task.completedDates.add(key);
        _logTaskReward(task.title);
      }
      await task.save();
    } else {
      final wasCompleted = task.isCompleted;
      task.isCompleted = !task.isCompleted;
      await task.save();
      if (!wasCompleted && task.isCompleted) _logTaskReward(task.title);
    }

    notifyListeners();
  }

  /// Pin/unpin a task as the Most Important Task for [date].
  /// Automatically unpins any other MIT on the same day.
  void toggleMIT(String id, DateTime date) async {
    final dayTasks = getTasksForDate(date);
    for (final t in dayTasks) {
      if (t.isMIT && t.id != id) {
        t.isMIT = false;
        await t.save();
      }
    }
    final task = _taskBox.get(id);
    if (task != null) {
      task.isMIT = !task.isMIT;
      await task.save();
    }
    notifyListeners();
  }

  void deleteTask(String id) async {
    await _taskBox.delete(id);
    notifyListeners();
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

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
}
