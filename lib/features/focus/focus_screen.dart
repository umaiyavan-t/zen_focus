import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/focus_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'app_selection_screen.dart';
import 'package:app_blocker/app_blocker.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with WidgetsBindingObserver {
  BlockerPermissionStatus _permissionStatus = BlockerPermissionStatus.denied;
  bool _isChecking = true;
  final _appBlocker = AppBlocker.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final status = await _appBlocker.checkPermission();

    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final isGranted = _permissionStatus == BlockerPermissionStatus.granted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.app_registration),
            tooltip: 'Block Apps',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppSelectionScreen()),
            ),
          ),
        ],
      ),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Stack(
              children: [
                _buildMainContent(context, focusProvider),
                if (!isGranted) _buildPermissionOverlay(),
                if (focusProvider.isBlockedAlertVisible) _buildFocusOverlay(context, focusProvider),
              ],
            ),
    );
  }

  Widget _buildPermissionOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, color: AppTheme.accentColor, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Setup Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'To block distractions, we need system permissions. Please click below to grant them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _appBlocker.requestPermission(),
              icon: const Icon(Icons.settings),
              label: const Text('GRANT PERMISSIONS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }


  

  Widget _buildMainContent(BuildContext context, FocusProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildStatusBadge(provider),
            const SizedBox(height: 40),
            _buildTimerDisplay(provider),
            const SizedBox(height: 60),
            if (!provider.isActive) _buildDurationSelector(provider),
            if (provider.isActive) _buildActiveControls(context, provider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(FocusProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: provider.isActive ? AppTheme.primaryColor : Colors.white24,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            provider.status,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(FocusProvider provider) {
    return CircularPercentIndicator(
      radius: 140.0,
      lineWidth: 4.0,
      percent: provider.secondsRemaining / (provider.initialSeconds > 0 ? provider.initialSeconds : 1),
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            provider.formatTime(),
            style: GoogleFonts.outfit(
              fontSize: 64,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
          Text(
            'remaining',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      progressColor: AppTheme.primaryColor,
      backgroundColor: Colors.white.withOpacity(0.05),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animateFromLastPercent: true,
    );
  }

  Widget _buildDurationSelector(FocusProvider provider) {
    final durations = [1, 10, 25, 45];
    return Column(
      children: [
        const Text(
          'Select your intention',
          style: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: durations.map((mins) {
            final isSelected = provider.secondsRemaining == mins * 60;
            return GestureDetector(
              onTap: () => provider.setDuration(mins),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.white10,
                  ),
                ),
                child: Text(
                  '${mins}m',
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.white38,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () => provider.startFocus(),
          child: const Text('BEGIN JOURNEY'),
        ),
      ],
    );
  }

  Widget _buildActiveControls(BuildContext context, FocusProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconButton(
              icon: provider.isPaused ? Icons.play_arrow : Icons.pause,
              onPressed: () {
                if (provider.isPaused) {
                  provider.resumeFocus();
                } else {
                  _showPauseDialog(context, provider);
                }
              },
            ),
            const SizedBox(width: 32),
            _buildIconButton(
              icon: Icons.stop,
              color: Colors.redAccent.withOpacity(0.8),
              onPressed: () => _showEndDialog(context, provider),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed, Color? color}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 32,
      color: color ?? AppTheme.primaryColor,
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.surfaceColor,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context, FocusProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Pause Focus?'),
        content: const Text('Pausing breaks the flow. Are you sure you want to stop temporarily?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              provider.pauseFocus();
              Navigator.pop(context);
            },
            child: const Text('PAUSE', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showEndDialog(BuildContext context, FocusProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('End Session Early?'),
        content: const Text('If you stop now, you will lose all reward points for this session. Your focus is valuable!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('STAY FOCUSED', style: TextStyle(color: AppTheme.primaryColor)),
          ),
          TextButton(
            onPressed: () {
              provider.stopFocus(completed: false);
              Navigator.pop(context);
            },
            child: const Text('END ANYWAY', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusOverlay(BuildContext context, FocusProvider provider) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.95),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa_outlined, color: AppTheme.primaryColor, size: 80),
            const SizedBox(height: 32),
            Text(
              'DEPTH OF FOCUS',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w200,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              provider.formatTime(),
              style: GoogleFonts.outfit(
                color: AppTheme.primaryColor,
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 80),
            TextButton(
              onPressed: () => _showEndDialog(context, provider),
              child: const Text('I MUST DISCONNECT', style: TextStyle(color: Colors.white10, letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }
}
