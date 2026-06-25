import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_homescreen_widget/flutter_homescreen_widget.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  FlutterHomescreenWidget.init(_navigatorKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'flutter_homescreen_widget example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ClockPage(),
    );
  }
}

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Wait for the navigator/overlay to be fully mounted before rendering
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      _updateWidgets();
    });
    // Update widget every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
      _updateWidgets();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateWidgets() async {
    final now = DateTime.now();
    setState(() => _now = now);

    try {
    // Medium widget: landscape clock
    await FlutterHomescreenWidget.update(
      widgetName: 'ClockWidget',
      size: const Size(329, 155),
      content: ClockWidgetMedium(now: now),
    );

    // Small widget: compact clock
    await FlutterHomescreenWidget.update(
      widgetName: 'ClockWidgetSmall',
      size: const Size(155, 155),
      content: ClockWidgetSmall(now: now),
    );
    } catch (e) {
      debugPrint('Widget update error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Widget Preview',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              // Medium preview
              SizedBox(
                width: 329,
                height: 155,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ClockWidgetMedium(now: _now),
                ),
              ),
              const SizedBox(height: 16),
              // Small preview
              SizedBox(
                width: 155,
                height: 155,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ClockWidgetSmall(now: _now),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Medium Widget (329 × 155) ────────────────────────────────────────────────

/// Glassmorphism-style medium clock widget.
class ClockWidgetMedium extends StatelessWidget {
  final DateTime now;
  const ClockWidgetMedium({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        _Background(),
        // Decorative circles
        Positioned(top: -40, right: -20, child: _GlowCircle(size: 160, color: Colors.purpleAccent.withOpacity(0.25))),
        Positioned(bottom: -30, left: 60, child: _GlowCircle(size: 100, color: Colors.blueAccent.withOpacity(0.2))),
        // Glass card
        Padding(
          padding: const EdgeInsets.all(16),
          child: _GlassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Time
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(now),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w200,
                            letterSpacing: -2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(now),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withOpacity(0.15),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  // Day + AM/PM
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dayOfWeek(now),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          now.hour < 12 ? 'AM' : 'PM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Small Widget (155 × 155) ─────────────────────────────────────────────────

/// Glassmorphism-style small clock widget.
class ClockWidgetSmall extends StatelessWidget {
  final DateTime now;
  const ClockWidgetSmall({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _Background(),
        Positioned(top: -30, right: -20, child: _GlowCircle(size: 110, color: Colors.purpleAccent.withOpacity(0.25))),
        Positioned(bottom: -20, left: -10, child: _GlowCircle(size: 80, color: Colors.blueAccent.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _GlassCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(now),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -1.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _dayOfWeek(now),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateShort(now),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

String _formatTime(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _formatDate(DateTime t) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[t.month - 1]} ${t.day}, ${t.year}';
}

String _formatDateShort(DateTime t) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[t.month - 1]} ${t.day}';
}

String _dayOfWeek(DateTime t) {
  const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return days[t.weekday - 1];
}

// ─── Reusable primitives ──────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 10)],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
