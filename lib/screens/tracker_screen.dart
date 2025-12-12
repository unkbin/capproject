import 'package:flutter/material.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  // Mood options
  final List<_Mood> moods = const [
    _Mood("Great", "😄", 5),
    _Mood("OK", "🙂", 4),
    _Mood("Neutral", "😐", 3),
    _Mood("Low", "😟", 2),
    _Mood("Drained", "😫", 1),
  ];
  int? selectedMoodValue;

  // Trackers
  double hydration = 5; // out of 12
  double movement = 20; // out of 120
  double sleep = 7.5; // out of 12

  // Fake streak
  int streak = 3;

  @override
  Widget build(BuildContext context) {
    final summaryMessage = _generateSummary();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's check-in",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StreakBadge(streak: streak),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Take a moment to log how you're doing today.",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Mood selector
          Text(
            "How are you feeling?",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _MoodSelector(
            moods: moods,
            selectedValue: selectedMoodValue,
            onChanged: (value) {
              setState(() => selectedMoodValue = value);
            },
          ),
          const SizedBox(height: 24),

          // Inputs section
          Text(
            "Today's inputs",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _TrackerCard(
            label: "Hydration",
            valueText: "${hydration.round()} / 12 glasses",
            slider: Slider(
              min: 0,
              max: 12,
              divisions: 12,
              value: hydration,
              onChanged: (v) => setState(() => hydration = v),
            ),
          ),
          const SizedBox(height: 12),
          _TrackerCard(
            label: "Movement",
            valueText: "${movement.round()} / 120 minutes",
            slider: Slider(
              min: 0,
              max: 120,
              divisions: 12,
              value: movement,
              onChanged: (v) => setState(() => movement = v),
            ),
          ),
          const SizedBox(height: 12),
          _TrackerCard(
            label: "Sleep (last night)",
            valueText: "${sleep.toStringAsFixed(1)} hours",
            slider: Slider(
              min: 0,
              max: 12,
              divisions: 24,
              value: sleep,
              onChanged: (v) => setState(() => sleep = v),
            ),
          ),
          const SizedBox(height: 24),

          // Summary card
          _SummaryCard(message: summaryMessage),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Save today's check-in"),
              onPressed: _saveToday,
            ),
          ),

          const SizedBox(height: 30),

          // Recent history section
          Text(
            "Recent trend",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _HistoryPreview(),
        ],
      ),
    );
  }

  // Generate simple summary rules
  String _generateSummary() {
    if (selectedMoodValue == null) {
      return "Select your mood to receive a personalised summary.";
    }

    if (selectedMoodValue! <= 2) {
      return "You're having a low day. Try gentle movement or a short mindfulness break.";
    }

    if (hydration < 6) {
      return "You're halfway to your hydration goal. A couple more glasses will help.";
    }

    if (movement < 30) {
      return "A short walk can help you reach your movement target.";
    }

    if (sleep < 6) {
      return "Your sleep was a bit low. Try a calming activity later today.";
    }

    return "Nice work today. You're on track with your habits.";
  }

  void _saveToday() {
    if (selectedMoodValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a mood.")),
      );
      return;
    }

    // Later: save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Check-in saved (demo only).")),
    );

    setState(() => streak += 1);
  }
}

/// Mood model
class _Mood {
  final String label;
  final String emoji;
  final int value;

  const _Mood(this.label, this.emoji, this.value);
}

/// Mood Selector widget
class _MoodSelector extends StatelessWidget {
  final List<_Mood> moods;
  final int? selectedValue;
  final ValueChanged<int> onChanged;

  const _MoodSelector({
    required this.moods,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: moods.map((m) {
        final selected = selectedValue == m.value;
        return GestureDetector(
          onTap: () => onChanged(m.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF4CAF50).withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade300,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  m.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                m.label,
                style: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Card wrapper for each slider input
class _TrackerCard extends StatelessWidget {
  final String label;
  final String valueText;
  final Widget slider;

  const _TrackerCard({
    required this.label,
    required this.valueText,
    required this.slider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
            const SizedBox(height: 4),
            Text(
              valueText,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            slider,
          ],
        ),
      ),
    );
  }
}

/// Summary card under check-in inputs
class _SummaryCard extends StatelessWidget {
  final String message;

  const _SummaryCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb, color: Colors.amber.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Streak badge
class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
        const SizedBox(width: 4),
        Text(
          "$streak days",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Simple 7-day trend preview
class _HistoryPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fakeDays = [
      "😀 7h 8gl",
      "🙂 6.5h 6gl",
      "😐 7h 7gl",
      "😄 8h 10gl",
      "🙂 7h 8gl",
      "😟 5h 5gl",
      "😄 7.5h 9gl",
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: fakeDays
                .map(
                  (e) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
}
