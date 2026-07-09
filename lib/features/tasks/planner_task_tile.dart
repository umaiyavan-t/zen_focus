import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/task_provider.dart';
import '../../../models/task_model.dart';

// ── Shared color/format helpers ───────────────────────────────────────────────

Color priorityColor(int p) {
  switch (p) {
    case 2:
      return const Color(0xFFCF6679); // High — warm red
    case 1:
      return AppTheme.accentColor; // Medium — muted sand
    default:
      return AppTheme.primaryColor; // Low — sage green
  }
}

String formatTimeSlot(String t) {
  final parts = t.split(':');
  final h = int.parse(parts[0]);
  final m = parts[1];
  final period = h >= 12 ? 'PM' : 'AM';
  final dh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
  return '$dh:$m $period';
}

String formatEstimate(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m > 0 ? '${h}h ${m}m' : '${h}h';
}

// ── PlannerCheckbox ───────────────────────────────────────────────────────────

class PlannerCheckbox extends StatelessWidget {
  final Task task;
  final DateTime date;
  final Color? color;

  const PlannerCheckbox({
    super.key,
    required this.task,
    required this.date,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDone = provider.isTaskCompletedOnDate(task, date);
    final c = color ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: () => context.read<TaskProvider>().toggleTaskStatus(task.id, date: date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isDone ? c : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDone ? c : Colors.white24,
            width: 1.5,
          ),
        ),
        child: isDone
            ? const Icon(Icons.check_rounded, size: 14, color: AppTheme.backgroundColor)
            : null,
      ),
    );
  }
}

// ── PlannerTaskTile ───────────────────────────────────────────────────────────

class PlannerTaskTile extends StatelessWidget {
  final Task task;
  final DateTime date;
  final bool showMITStar;

  const PlannerTaskTile({
    super.key,
    required this.task,
    required this.date,
    this.showMITStar = true,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDone = provider.isTaskCompletedOnDate(task, date);
    final pc = priorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDone
            ? Colors.white.withOpacity(0.02)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? Colors.white.withOpacity(0.04)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          // Priority dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: isDone ? Colors.white12 : pc,
              shape: BoxShape.circle,
            ),
          ),

          PlannerCheckbox(task: task, date: date),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isDone ? Colors.white24 : Colors.white70,
                    fontWeight: FontWeight.w300,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white24,
                  ),
                ),
                if (task.isRecurring || task.estimatedMinutes != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (task.isRecurring) ...[
                        const Icon(Icons.repeat_rounded,
                            size: 10, color: Colors.white24),
                        const SizedBox(width: 3),
                        Text(
                          'Daily',
                          style: GoogleFonts.outfit(
                              fontSize: 10, color: Colors.white24),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (task.estimatedMinutes != null)
                        _EstimateBadge(minutes: task.estimatedMinutes!),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // MIT star toggle
          if (showMITStar)
            GestureDetector(
              onTap: () =>
                  context.read<TaskProvider>().toggleMIT(task.id, date),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    task.isMIT
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    key: ValueKey(task.isMIT),
                    size: 18,
                    color:
                        task.isMIT ? AppTheme.accentColor : Colors.white12,
                  ),
                ),
              ),
            ),

          // Delete
          GestureDetector(
            onTap: () => context.read<TaskProvider>().deleteTask(task.id),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 16, color: Colors.white12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MIT Card ──────────────────────────────────────────────────────────────────

class MITCard extends StatelessWidget {
  final Task task;
  final DateTime date;

  const MITCard({super.key, required this.task, required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDone = provider.isTaskCompletedOnDate(task, date);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(0.12),
            AppTheme.accentColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppTheme.accentColor, size: 14),
              const SizedBox(width: 6),
              Text(
                'MOST IMPORTANT TASK',
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PlannerCheckbox(
                  task: task, date: date, color: AppTheme.accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDone ? Colors.white30 : Colors.white,
                    fontWeight: FontWeight.w300,
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white30,
                  ),
                ),
              ),
              if (task.estimatedMinutes != null) ...[
                const SizedBox(width: 8),
                _EstimateBadge(minutes: task.estimatedMinutes!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── _EstimateBadge ────────────────────────────────────────────────────────────

class _EstimateBadge extends StatelessWidget {
  final int minutes;
  const _EstimateBadge({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.15)),
      ),
      child: Text(
        formatEstimate(minutes),
        style: GoogleFonts.outfit(
          fontSize: 9,
          color: AppTheme.accentColor.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
