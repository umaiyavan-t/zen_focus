import 'package:hive/hive.dart';

part 'reward_model.g.dart';

@HiveType(typeId: 4)
class Reward extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int points;

  @HiveField(3)
  final DateTime timestamp;

  Reward({
    required this.id,
    required this.title,
    required this.points,
    required this.timestamp,
  });
}
