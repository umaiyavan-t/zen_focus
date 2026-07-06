import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/journal_provider.dart';
import '../../models/journal_model.dart';
import 'package:intl/intl.dart';

import 'package:google_fonts/google_fonts.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _noteController = TextEditingController();
  String _selectedMood = '😊';
  final List<String> _moods = ['😊', '😌', '😐', '😔', '😫'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveEntry(BuildContext context) {
    if (_noteController.text.isNotEmpty) {
      context.read<JournalProvider>().addEntry(_selectedMood, _noteController.text);
      _noteController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = context.watch<JournalProvider>();
    final entries = journalProvider.entries;

    return Scaffold(
      appBar: AppBar(title: const Text('JOURNAL')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildZenHeader(),
            const SizedBox(height: 48),
            _buildMoodGrid(),
            const SizedBox(height: 48),
            _buildReflectionInput(),
            const SizedBox(height: 60),
            _buildPreviousDays(entries),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildZenHeader() {
    return Column(
      children: [
        Text(
          'BE STILL AND KNOW',
          style: GoogleFonts.outfit(
            fontSize: 10,
            letterSpacing: 4,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'How is your soul today?',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w200,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _moods.map((mood) {
        final isSelected = _selectedMood == mood;
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.white10,
              ),
            ),
            child: Text(mood, style: const TextStyle(fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReflectionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DAILY REFLECTION',
          style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white24),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          maxLines: 4,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w300),
          decoration: InputDecoration(
            hintText: 'Writing is the geometry of the soul...',
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: AppTheme.surfaceColor.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Colors.white10),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveEntry(context),
            child: const Text('PRESERVE REFLECTION'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousDays(List<JournalEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PREVIOUS REFLECTIONS',
          style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white24),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return _buildEntryZenCard(entries[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildEntryZenCard(JournalEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.mood, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM dd, yyyy').format(entry.date).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.note,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white10, size: 18),
            onPressed: () => context.read<JournalProvider>().deleteEntry(index),
          ),
        ],
      ),
    );
  }
}
