import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  int points;

  @HiveField(2)
  String? avatarUrl;

  User({
    required this.username,
    this.points = 0,
    this.avatarUrl,
  });
}
