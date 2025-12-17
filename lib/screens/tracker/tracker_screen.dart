import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'tracker_history_screen.dart';
import 'tracker_service.dart';
import 'tracker_widgets.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final _service = const TrackerService();

  String _mood = 'Okay';
  double _hydration = 50;
  double _movement = 30;
  double _sleep = 7;

  bool _loading = true;
  bool _saving = false;
  int _streak = 0;

  String get _todayId => TrackerService.dateId(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final entry = await _service.loadDay(user.uid, _todayId);
      final streak = await _service.computeStreak(user.uid);

      if (!mounted) return;

      if (entry != null) {
        setState(() {
          _mood = entry.mood;
          _hydration = entry.hydration;
          _movement = entry.movement;
          _sleep = entry.sleep;
          _streak = streak;
        });
      } else {
        setState(() => _streak = streak);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save your check-in.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final entry = TrackerEntry(
        dateId: _todayId,
        mood: _mood,
        hydration: _hydration,
        movement: _movement,
        sleep: _sleep,
        updatedAt: null,
      );

      await _service.saveDay(user.uid, entry);
      final streak = await _service.computeStreak(user.uid);

      if (!mounted) return;
      setState(() => _streak = streak);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved for today.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tracker',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrackerHistoryScreen()),
                );
              },
              child: const Text('History'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'A short check-in for today.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MiniStatPill(
              label: 'Streak',
              value: '$_streak day${_streak == 1 ? '' : 's'}',
              icon: Icons.local_fire_department_outlined,
            ),
            MiniStatPill(label: 'Today', value: _todayId, icon: Icons.today_outlined),
          ],
        ),

        const SizedBox(height: 14),

        TrackerSectionCard(
          title: 'Mood',
          child: MoodChoiceRow(
            value: _mood,
            onChanged: (v) => setState(() => _mood = v),
          ),
        ),
        const SizedBox(height: 12),

        TrackerSectionCard(
          title: 'Hydration',
          subtitle: '${_hydration.round()}%',
          child: Slider(
            value: _hydration,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_hydration.round()}%',
            onChanged: (v) => setState(() => _hydration = v),
          ),
        ),
        const SizedBox(height: 12),

        TrackerSectionCard(
          title: 'Movement',
          subtitle: '${_movement.round()} min',
          child: Slider(
            value: _movement,
            min: 0,
            max: 120,
            divisions: 24,
            label: '${_movement.round()} min',
            onChanged: (v) => setState(() => _movement = v),
          ),
        ),
        const SizedBox(height: 12),

        TrackerSectionCard(
          title: 'Sleep',
          subtitle: '${_sleep.toStringAsFixed(1)} hrs',
          child: Slider(
            value: _sleep,
            min: 0,
            max: 12,
            divisions: 24,
            label: '${_sleep.toStringAsFixed(1)} hrs',
            onChanged: (v) => setState(() => _sleep = v),
          ),
        ),

        const SizedBox(height: 18),

        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving...' : 'Save today'),
        ),

        const SizedBox(height: 8),

        Text(
          'Saved under: users/{uid}/checkins/$_todayId',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
