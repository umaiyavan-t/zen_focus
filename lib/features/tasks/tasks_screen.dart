import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'package:provider/provider.dart';

import '../../core/providers/task_provider.dart';
import '../../models/task_model.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _showAddTaskSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 40,
          left: 32,
          right: 32,
          top: 32,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEW INTENTION',
              style: GoogleFonts.outfit(
                fontSize: 12,
                letterSpacing: 4,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                hintText: 'What needs your focus?',
                hintStyle: const TextStyle(color: Colors.white10),
                filled: true,
                fillColor: Colors.white.withOpacity(0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<TaskProvider>().addTask(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TASKS'),
      ),
      body: tasks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskItem(context, task);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, color: AppTheme.backgroundColor, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_outlined, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text(
            'Clear your mind. Start small.',
            style: TextStyle(color: Colors.white24, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: task.isCompleted ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          _buildCheckbox(context, task),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.outfit(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.white24 : Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white10, size: 18),
            onPressed: () => context.read<TaskProvider>().deleteTask(task.id),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, Task task) {
    return GestureDetector(
      onTap: () => context.read<TaskProvider>().toggleTaskStatus(task.id),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: task.isCompleted ? AppTheme.primaryColor : Colors.white24,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.check_rounded,
          size: 16,
          color: task.isCompleted ? AppTheme.backgroundColor : Colors.transparent,
        ),
      ),
    );
  }
}
