import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour);
    final dateLabel = _formatDate(now);

    final stats = <DailyStat>[
      DailyStat('Hydration', '5 / 8 glasses', 5 / 8),
      DailyStat('Movement', '25 / 30 min', 25 / 30),
      DailyStat('Sleep', '7.5 h', 7.5 / 8),
    ];

    final planItems = <PlanItem>[
      PlanItem(
        type: 'Nutrition',
        title: 'Morning Recipe',
        subtitle: 'Golden turmeric smoothie',
        tag: '5 min • Easy',
        icon: Icons.local_drink,
      ),
      PlanItem(
        type: 'Movement',
        title: 'Movement break',
        subtitle: '10 min gentle stretch',
        tag: 'Low impact • Home',
        icon: Icons.fitness_center,
      ),
      PlanItem(
        type: 'Mindfulness',
        title: 'Mindfulness moment',
        subtitle: '5 min breathing reset',
        tag: 'Beginner • Calm',
        icon: Icons.self_improvement,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + date
          Text(
            '$greeting, Nabin',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Snapshot
          _SnapshotCard(
            text: 'You’ve completed 2 of 3 habits today. Nice work.',
          ),
          const SizedBox(height: 16),

          // Quick stats
          Text(
            'Today at a glance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _StatsRow(stats: stats),
          const SizedBox(height: 24),

          // Wellness plan
          Text(
            'Today’s wellness plan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in planItems) _PlanCard(item: item),
          const SizedBox(height: 24),

          // Card of the day
          Text(
            'Card of the day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to reveal a small focus for today.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          const _CardOfTheDay(),
          const SizedBox(height: 24),

          // Quick actions
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _QuickActions(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month';
  }
}

/// Simple data models

class DailyStat {
  final String label;
  final String value;
  final double progress; // 0.0–1.0

  DailyStat(this.label, this.value, this.progress);
}

class PlanItem {
  final String type;
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;

  PlanItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
  });
}

/// Widgets for sections

class _SnapshotCard extends StatelessWidget {
  final String text;

  const _SnapshotCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<DailyStat> stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _StatCard(stat: stat);
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final DailyStat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.value,
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: stat.progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PlanItem item;

  const _PlanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: const Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // later: open detail or start flow
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening: ${item.title} (coming soon)'),
                  ),
                );
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardOfTheDay extends StatefulWidget {
  const _CardOfTheDay();

  @override
  State<_CardOfTheDay> createState() => _CardOfTheDayState();
}

class _CardOfTheDayState extends State<_CardOfTheDay> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showBack = !_showBack;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        height: 170,
        decoration: BoxDecoration(
          color: _showBack ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 4),
              color: Colors.black12,
            ),
          ],
        ),
        child: Center(
          child: _showBack
              ? const Text(
            'Pause three times today to take\n3 slow breaths.\n\nNotice how your body feels.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          )
              : const Text(
            'Tap to reveal today’s focus.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                  Text('Go to the Tracker tab to log today’s check-in.'),
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Log today’s check-in'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bookings screen coming soon.'),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Book a session'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                      Text('Journal feature will be added in a later phase.'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Open journal'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
