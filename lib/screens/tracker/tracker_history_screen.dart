import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'tracker_service.dart';

class TrackerHistoryScreen extends StatefulWidget {
  const TrackerHistoryScreen({super.key});

  @override
  State<TrackerHistoryScreen> createState() => _TrackerHistoryScreenState();
}

class _TrackerHistoryScreenState extends State<TrackerHistoryScreen> {
  final _service = const TrackerService();

  bool _loading = true;
  List<TrackerEntry> _items = const [];
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final items = await _service.loadRecentDays(user.uid, limit: 7);
      final streak = await _service.computeStreak(user.uid);

      if (!mounted) return;
      setState(() {
        _items = items;
        _streak = streak;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const Center(child: Text('Please log in to view history.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Streak: $_streak day${_streak == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          if (_items.isEmpty)
            const Text('No check-ins yet.')
          else
            for (final e in _items)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(e.dateId),
                  subtitle: Text(
                    '${e.mood} • ${e.hydration.round()}% • ${e.movement.round()} min • ${e.sleep.toStringAsFixed(1)} hrs',
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
