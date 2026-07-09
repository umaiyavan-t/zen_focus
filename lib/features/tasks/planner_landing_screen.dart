import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/task_provider.dart';
import '../../models/task_model.dart';
import 'planner_task_tile.dart';
import 'tasks_screen.dart';

class PlannerLandingScreen extends StatefulWidget {
  const PlannerLandingScreen({super.key});

  @override
  State<PlannerLandingScreen> createState() => _PlannerLandingScreenState();
}

class _PlannerLandingScreenState extends State<PlannerLandingScreen> {
  DateTime _selectedDate = TaskProvider.normalizeDate(DateTime.now());
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final today = TaskProvider.normalizeDate(DateTime.now());
    final dayOfWeek = today.weekday; // 1 = Mon, 7 = Sun
    _weekStart = today.subtract(Duration(days: dayOfWeek - 1));
    _selectedDate = today;
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  // ── Unified Add Task Sheet ──────────────────────────────────────────────────

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    bool isWeeklySelected = false; // Choose Daily vs Weekly
    int priority = 1;
    String? timeSlot;
    int? estimatedMinutes;
    bool isRecurring = false;
    bool isMIT = false;

    const timeSlots = [
      '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
      '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
      '18:00', '19:00', '20:00', '21:00', '22:00',
    ];
    const estimateOptions = [15, 30, 45, 60, 90, 120];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text(
                  'NEW PLANNING INTENTION',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    letterSpacing: 4,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Title input
                TextField(
                  controller: titleController,
                  autofocus: true,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What needs your focus?',
                    hintStyle: const TextStyle(color: Colors.white12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: AppTheme.primaryColor.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Type Picker (Daily vs Weekly)
                const _SheetLabel('PLANNER SCOPE'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() => isWeeklySelected = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isWeeklySelected
                                ? AppTheme.primaryColor.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !isWeeklySelected
                                  ? AppTheme.primaryColor
                                  : Colors.white10,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Daily Task',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: !isWeeklySelected
                                    ? AppTheme.primaryColor
                                    : Colors.white38,
                                fontWeight: !isWeeklySelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() => isWeeklySelected = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isWeeklySelected
                                ? AppTheme.accentColor.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isWeeklySelected
                                  ? AppTheme.accentColor
                                  : Colors.white10,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Weekly Goal',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: isWeeklySelected
                                    ? AppTheme.accentColor
                                    : Colors.white38,
                                fontWeight: isWeeklySelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Priority picker
                const _SheetLabel('PRIORITY'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _PriorityChip(
                      label: 'LOW',
                      value: 0,
                      current: priority,
                      color: AppTheme.primaryColor,
                      onTap: () => setSheet(() => priority = 0),
                    ),
                    const SizedBox(width: 8),
                    _PriorityChip(
                      label: 'MEDIUM',
                      value: 1,
                      current: priority,
                      color: AppTheme.accentColor,
                      onTap: () => setSheet(() => priority = 1),
                    ),
                    const SizedBox(width: 8),
                    _PriorityChip(
                      label: 'HIGH',
                      value: 2,
                      current: priority,
                      color: const Color(0xFFCF6679),
                      onTap: () => setSheet(() => priority = 2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Time slot selection (Only visible if Daily)
                if (!isWeeklySelected) ...[
                  const _SheetLabel('TIME SLOT'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: timeSlots.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final slot = timeSlots[i];
                        final sel = timeSlot == slot;
                        return GestureDetector(
                          onTap: () =>
                              setSheet(() => timeSlot = sel ? null : slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.primaryColor.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel
                                    ? AppTheme.primaryColor.withOpacity(0.4)
                                    : Colors.white10,
                              ),
                            ),
                            child: Text(
                              formatTimeSlot(slot),
                              style: GoogleFonts.outfit(
                                color: sel
                                    ? AppTheme.primaryColor
                                    : Colors.white38,
                                fontSize: 12,
                                fontWeight: sel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Estimated time chips
                const _SheetLabel('ESTIMATED TIME'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: estimateOptions.map((mins) {
                    final sel = estimatedMinutes == mins;
                    return GestureDetector(
                      onTap: () => setSheet(
                          () => estimatedMinutes = sel ? null : mins),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.accentColor.withOpacity(0.14)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel
                                ? AppTheme.accentColor.withOpacity(0.4)
                                : Colors.white10,
                          ),
                        ),
                        child: Text(
                          formatEstimate(mins),
                          style: GoogleFonts.outfit(
                            color: sel
                                ? AppTheme.accentColor
                                : Colors.white38,
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Toggles
                Row(
                  children: [
                    if (!isWeeklySelected) ...[
                      Expanded(
                        child: _ToggleChip(
                          label: '🔄  Recurring Daily',
                          value: isRecurring,
                          onChanged: (v) => setSheet(() => isRecurring = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ToggleChip(
                          label: '⭐  Most Important',
                          value: isMIT,
                          onChanged: (v) => setSheet(() => isMIT = v),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;
                      context.read<TaskProvider>().addPlannedTask(
                            title: title,
                            scheduledDate: isRecurring ? null : _selectedDate,
                            priority: priority,
                            timeSlot: timeSlot,
                            isRecurring: isRecurring,
                            estimatedMinutes: estimatedMinutes,
                            isMIT: isMIT,
                            isWeekly: isWeeklySelected,
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('ADD TO PLANNER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dashboard Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final streak = provider.getStreakCount();

    // Stats calculations
    final today = TaskProvider.normalizeDate(DateTime.now());
    final todayDone = provider.getCompletedCountForDate(today);
    final todayTotal = provider.getTotalCountForDate(today);
    final todayRate = todayTotal == 0 ? 0.0 : todayDone / todayTotal;

    final selectedDayTasks = provider.getTasksForDate(_selectedDate);
    final selectedDayDone = provider.getCompletedCountForDate(_selectedDate);
    final selectedDayTotal = provider.getTotalCountForDate(_selectedDate);
    final selectedDayRate = selectedDayTotal == 0 ? 0.0 : selectedDayDone / selectedDayTotal;

    final weekStats = provider.getWeeklyStats(_weekStart);
    final double weeklyRate = weekStats['rate'] as double;
    final int weeklyCompleted = weekStats['totalCompleted'] as int;
    final int weeklyTotal = weekStats['totalTasks'] as int;

    // Heatmap data (7 weeks)
    final heatmapData = provider.getHeatmapData(weeks: 7);

    // List of day names
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Tasks grouped for the selected day list
    final mitTask = selectedDayTasks.where((t) => t.isMIT).firstOrNull;
    final nonMit = selectedDayTasks.where((t) => !t.isMIT).toList();
    final timed = nonMit.where((t) => t.timeSlot != null).toList();
    final untimed = nonMit.where((t) => t.timeSlot == null).toList();

    final slotMap = <String, List<Task>>{};
    for (final t in timed) {
      slotMap.putIfAbsent(t.timeSlot!, () => []).add(t);
    }
    final sortedSlots = slotMap.keys.toList()..sort();

    // Weekly focus intentions for selected date's week
    final weeklyTasks = provider.getWeeklyTasksForDate(_selectedDate);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Text(
                'PLANNER',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  letterSpacing: 4,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your center.',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Today & Streak stats widgets
              Row(
                children: [
                  _QuickStat(
                    label: 'TODAY',
                    value: todayTotal == 0 ? 'No tasks' : '$todayDone/$todayTotal',
                    icon: Icons.task_alt_outlined,
                    color: AppTheme.primaryColor,
                    progress: todayRate,
                  ),
                  const SizedBox(width: 12),
                  _QuickStat(
                    label: 'STREAK',
                    value: streak == 0 ? 'Start one!' : '$streak day${streak > 1 ? 's' : ''}',
                    icon: streak > 0 ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
                    color: streak > 0 ? const Color(0xFFFF8C55) : Colors.white24,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Calendar Strip (Horizontal date navigator) ──────────────────
              _buildWeekHeader(),
              const SizedBox(height: 12),
              _buildWeekStrip(provider, dayNames),
              const SizedBox(height: 24),

              // ── Daily Progress & Weekly Progress Card ───────────────────────
              _buildProgressCard(
                selectedDayRate: selectedDayRate,
                selectedDayDone: selectedDayDone,
                selectedDayTotal: selectedDayTotal,
                weeklyRate: weeklyRate,
                weeklyCompleted: weeklyCompleted,
                weeklyTotal: weeklyTotal,
              ),
              const SizedBox(height: 12),

              // View All Tasks Highlighted Link
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TasksScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list_rounded, size: 18, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'VIEW ALL TASKS',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Heatmap Focus Grid ──────────────────────────────────────────
              _buildSectionHeader('HABIT HEATMAP'),
              const SizedBox(height: 12),
              _buildHeatmap(heatmapData),

              const SizedBox(height: 28),

              // ── Daily Focus Task List ───────────────────────────────────────
              _buildSectionHeader(
                'DAILY FOCUS — ${dayNames[_selectedDate.weekday - 1].toUpperCase()} (${_selectedDate.day}/${_selectedDate.month})',
              ),
              const SizedBox(height: 12),

              if (selectedDayTasks.isEmpty)
                _buildEmptyDayState()
              else ...[
                // MIT Card if any
                if (mitTask != null) ...[
                  MITCard(task: mitTask, date: _selectedDate),
                  const SizedBox(height: 16),
                ],

                // Time blocked sections
                for (final slot in sortedSlots) ...[
                  _SlotHeader(label: formatTimeSlot(slot)),
                  const SizedBox(height: 8),
                  ...slotMap[slot]!.map((t) => PlannerTaskTile(task: t, date: _selectedDate)),
                  const SizedBox(height: 16),
                ],

                // Untimed Flexible Tasks
                if (untimed.isNotEmpty) ...[
                  _SlotHeader(
                    label: sortedSlots.isNotEmpty ? 'FLEXIBLE' : 'TASKS',
                  ),
                  const SizedBox(height: 8),
                  ...untimed.map((t) => PlannerTaskTile(task: t, date: _selectedDate)),
                ],
              ],

              const SizedBox(height: 28),

              // ── Weekly Focus Intentions List ────────────────────────────────
              _buildSectionHeader('WEEKLY FOCUS GOALS'),
              const SizedBox(height: 12),

              if (weeklyTasks.isEmpty)
                _buildEmptyWeeklyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weeklyTasks.length,
                  itemBuilder: (context, index) {
                    final t = weeklyTasks[index];
                    return PlannerTaskTile(task: t, date: _selectedDate, showMITStar: false);
                  },
                ),

              const SizedBox(height: 80), // buffer space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, color: AppTheme.backgroundColor),
        label: Text(
          'Add Task',
          style: GoogleFonts.outfit(
            color: AppTheme.backgroundColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────────

  Widget _buildWeekHeader() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final startLabel = '${months[_weekStart.month - 1]} ${_weekStart.day}';
    final endLabel = '${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekEnd.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _previousWeek,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left_rounded, color: Colors.white38, size: 20),
          ),
        ),
        Text(
          '$startLabel – $endLabel',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
        GestureDetector(
          onTap: _nextWeek,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekStrip(TaskProvider provider, List<String> dayNames) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = _weekStart.add(Duration(days: index));
        final isSelected = _selectedDate == day;
        final completionRate = provider.getCompletionRateForDate(day);
        final hasTasks = provider.getTotalCountForDate(day) > 0;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.15)
                    : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.white10,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    dayNames[index],
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppTheme.primaryColor : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${day.day}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 14,
                    height: 4,
                    decoration: BoxDecoration(
                      color: !hasTasks
                          ? Colors.white10
                          : Color.lerp(
                              Colors.white24,
                              AppTheme.primaryColor,
                              completionRate,
                            ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProgressCard({
    required double selectedDayRate,
    required int selectedDayDone,
    required int selectedDayTotal,
    required double weeklyRate,
    required int weeklyCompleted,
    required int weeklyTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Daily progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
              ),
              Text(
                selectedDayTotal == 0 ? 'No tasks' : '$selectedDayDone/$selectedDayTotal done',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: selectedDayRate,
              minHeight: 5,
              backgroundColor: Colors.white10,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 20),

          // Weekly progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
              ),
              Text(
                weeklyTotal == 0 ? 'No tasks' : '$weeklyCompleted/$weeklyTotal done',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: weeklyRate,
              minHeight: 5,
              backgroundColor: Colors.white10,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 10,
            letterSpacing: 2,
            color: Colors.white30,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 0.5, color: Colors.white10)),
      ],
    );
  }

  Widget _buildHeatmap(List<MapEntry<DateTime, double>> heatmapData) {
    if (heatmapData.isEmpty) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(
          'No activity recorded yet.',
          style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Focus Grid',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60),
              ),
              Row(
                children: [
                  Text('Less', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white24)),
                  const SizedBox(width: 4),
                  _buildLegendBox(0.0),
                  const SizedBox(width: 2),
                  _buildLegendBox(0.3),
                  const SizedBox(width: 2),
                  _buildLegendBox(0.6),
                  const SizedBox(width: 2),
                  _buildLegendBox(1.0),
                  const SizedBox(width: 4),
                  Text('More', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white24)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DayLabel('M'),
                  _DayLabel(''),
                  _DayLabel('W'),
                  _DayLabel(''),
                  _DayLabel('F'),
                  _DayLabel(''),
                  _DayLabel('S'),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(7, (weekIdx) {
                      return Column(
                        children: List.generate(7, (dayIdx) {
                          final flatIdx = weekIdx * 7 + dayIdx;
                          if (flatIdx >= heatmapData.length) {
                            return _buildGridCell(null);
                          }
                          final entry = heatmapData[flatIdx];
                          return _buildGridCell(entry.value);
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(double val) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: _getHeatmapColor(val),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildGridCell(double? val) => Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: val == null ? Colors.transparent : _getHeatmapColor(val),
          borderRadius: BorderRadius.circular(3),
        ),
      );

  Color _getHeatmapColor(double val) {
    if (val == 0.0) return Colors.white.withOpacity(0.04);
    if (val <= 0.3) return AppTheme.primaryColor.withOpacity(0.25);
    if (val <= 0.7) return AppTheme.primaryColor.withOpacity(0.6);
    return AppTheme.primaryColor;
  }

  Widget _buildEmptyDayState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No daily tasks planned for this day.',
          style: GoogleFonts.outfit(color: Colors.white24, fontSize: 13, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  Widget _buildEmptyWeeklyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'No weekly focus goals scheduled for this week.',
          style: GoogleFonts.outfit(color: Colors.white24, fontSize: 13, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}

// ── Shared Sub-widgets ───────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: color.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white10,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlotHeader extends StatelessWidget {
  final String label;
  const _SlotHeader({required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              letterSpacing: 2,
              color: Colors.white30,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 0.5, color: Colors.white10)),
        ],
      );
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 10,
          letterSpacing: 2,
          color: Colors.white24,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final int value;
  final int current;
  final Color color;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.value,
    required this.current,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color.withOpacity(0.5) : Colors.white10,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  letterSpacing: 1,
                  color: selected ? color : Colors.white24,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: value ? Colors.white.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? Colors.white12 : Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: value ? Colors.white70 : Colors.white24,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w500),
      ),
    );
  }
}
