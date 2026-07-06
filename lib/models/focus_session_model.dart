import 'package:hive/hive.dart';

part 'focus_session_model.g.dart';

@HiveType(typeId: 3)
class FocusSession extends HiveObject {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  int durationMinutes;

  @HiveField(2)
  bool completed;

  FocusSession({
    required this.startTime,
    required this.durationMinutes,
    this.completed = true,
  });
}
