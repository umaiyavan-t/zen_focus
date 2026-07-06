import 'package:hive/hive.dart';

part 'journal_model.g.dart';

@HiveType(typeId: 2)
class JournalEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String mood; // emoji or text

  @HiveField(2)
  String note;

  JournalEntry({
    required this.date,
    required this.mood,
    required this.note,
  });
}
