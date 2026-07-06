import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/journal_model.dart';

class JournalProvider with ChangeNotifier {
  final Box<JournalEntry> _journalBox = Hive.box<JournalEntry>('journal');

  List<JournalEntry> get entries => _journalBox.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  void addEntry(String mood, String note) async {
    final entry = JournalEntry(
      date: DateTime.now(),
      mood: mood,
      note: note,
    );
    await _journalBox.add(entry);
    notifyListeners();
  }

  void deleteEntry(int index) async {
    await _journalBox.deleteAt(index);
    notifyListeners();
  }
}
