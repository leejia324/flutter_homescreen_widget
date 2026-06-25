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
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    FlutterHomescreenWidget.onAction.listen((actionId) {
      if (actionId == 'increment') _changeCount(1);
      if (actionId == 'decrement') _changeCount(-1);
    });
  }

  Future<void> _changeCount(int delta) async {
    setState(() => _count += delta);
    await _updateWidgets();
  }

  Future<void> _updateWidgets() async {
    // Medium widget: landscape layout with +/- buttons
    await FlutterHomescreenWidget.update(
      widgetName: 'CounterWidget',
      size: const Size(329, 155),
      content: CounterWidgetMedium(count: _count),
      actions: [
        WidgetAction(
          id: 'increment',
          area: const Rect.fromLTWH(0.65, 0.0, 0.35, 0.5),
        ),
        WidgetAction(
          id: 'decrement',
          area: const Rect.fromLTWH(0.65, 0.5, 0.35, 0.5),
        ),
      ],
    );

    // Small widget: square layout, full tap = increment
    await FlutterHomescreenWidget.update(
      widgetName: 'CounterWidgetSmall',
      size: const Size(155, 155),
      content: CounterWidgetSmall(count: _count),
      actions: [
        WidgetAction(
          id: 'increment',
          area: const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Widget Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: $_count', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _changeCount(-1),
                  child: const Text('-'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _changeCount(1),
                  child: const Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Medium widget UI — landscape layout with increment/decrement buttons.
class CounterWidgetMedium extends StatelessWidget {
  final int count;
  const CounterWidgetMedium({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Counter',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(label: '+'),
              const SizedBox(height: 10),
              _ActionButton(label: '−'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small widget UI — square layout, tap anywhere to increment.
class CounterWidgetSmall extends StatelessWidget {
  final int count;
  const CounterWidgetSmall({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Counter',
              style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tap to +1',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  const _ActionButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 20)),
    );
  }
}
