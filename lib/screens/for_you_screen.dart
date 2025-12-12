import 'package:flutter/material.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  String _selectedFilter = 'All';

  // Mock recommended content (later you can load this from a database)
  final List<ContentItem> _allItems = [
    ContentItem(
      id: 'breath_5',
      title: '5-min mindful breathing',
      description: 'Helps reduce stress and reset your focus.',
      type: 'Mindfulness',
      durationMinutes: 5,
      difficulty: 'Beginner',
      tags: ['stress', 'short', 'anytime'],
    ),
    ContentItem(
      id: 'body_scan_10',
      title: '10-min body scan',
      description: 'Gentle scan to relax your muscles before sleep.',
      type: 'Mindfulness',
      durationMinutes: 10,
      difficulty: 'Easy',
      tags: ['sleep', 'evening', 'relax'],
    ),
    ContentItem(
      id: 'stretch_morning',
      title: 'Morning stretch routine',
      description: 'Low-impact movements to wake up your body.',
      type: 'Movement',
      durationMinutes: 8,
      difficulty: 'Easy',
      tags: ['morning', 'low_impact'],
    ),
    ContentItem(
      id: 'walk_15',
      title: '15-min mindful walk',
      description: 'Combine light movement with mindful noticing.',
      type: 'Movement',
      durationMinutes: 15,
      difficulty: 'Moderate',
      tags: ['stress', 'outdoor'],
    ),
    ContentItem(
      id: 'sleep_hygiene',
      title: 'Better sleep checklist',
      description: 'Simple steps to prepare your body for rest.',
      type: 'Sleep',
      durationMinutes: 4,
      difficulty: 'Beginner',
      tags: ['sleep', 'short', 'evening'],
    ),
    ContentItem(
      id: 'anti_inflam_meal',
      title: 'Anti-inflammatory dinner idea',
      description: 'A simple meal to support recovery and mood.',
      type: 'Nutrition',
      durationMinutes: 20,
      difficulty: 'Easy',
      tags: ['nutrition', 'evening'],
    ),
  ];

  final List<ContentItem> _savedItems = [
    ContentItem(
      id: 'gratitude_3',
      title: '3-min gratitude pause',
      description: 'Quick reflection to end your day.',
      type: 'Mindfulness',
      durationMinutes: 3,
      difficulty: 'Beginner',
      tags: ['short', 'evening'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems();
    final topPick = filtered.isNotEmpty ? filtered.first : null;

    // Sections based on simple tag rules
    final lowSleepItems =
    filtered.where((item) => item.tags.contains('sleep')).toList();
    final shortItems =
    filtered.where((item) => item.durationMinutes <= 5).toList();
    final otherItems = filtered
        .where((item) =>
    !lowSleepItems.contains(item) && !shortItems.contains(item))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'For you',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your recent check-ins and interests.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          _FilterRow(
            selected: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty) ...[
            _EmptyState(onGoToTracker: () {
              // Later: navigate to Tracker tab
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Log today in the Tracker to get better suggestions.',
                  ),
                ),
              );
            }),
          ] else ...[
            // Top pick
            if (topPick != null) ...[
              _TopPickCard(item: topPick),
              const SizedBox(height: 20),
            ],

            // Sections
            if (lowSleepItems.isNotEmpty) ...[
              _SectionTitle('Because you logged low sleep'),
              const SizedBox(height: 8),
              for (final item in lowSleepItems)
                _ContentCard(item: item, dense: true),
              const SizedBox(height: 16),
            ],

            if (shortItems.isNotEmpty) ...[
              _SectionTitle('To keep your streak going'),
              const SizedBox(height: 8),
              for (final item in shortItems)
                _ContentCard(item: item, dense: true),
              const SizedBox(height: 16),
            ],

            if (otherItems.isNotEmpty) ...[
              _SectionTitle('You may like'),
              const SizedBox(height: 8),
              for (final item in otherItems) _ContentCard(item: item),
              const SizedBox(height: 16),
            ],

            // Saved items
            if (_savedItems.isNotEmpty) ...[
              _SectionTitle('Saved for later'),
              const SizedBox(height: 8),
              for (final item in _savedItems)
                _ContentCard(item: item, isSaved: true, dense: true),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  /// Filter items by type based on the selected chip.
  List<ContentItem> _filteredItems() {
    if (_selectedFilter == 'All') return _allItems;

    return _allItems
        .where((item) => item.type.toLowerCase() ==
        _selectedFilter.toLowerCase())
        .toList();
  }
}

/// Simple content model
class ContentItem {
  final String id;
  final String title;
  final String description;
  final String type; // Mindfulness, Movement, Nutrition, Sleep
  final int durationMinutes;
  final String difficulty;
  final List<String> tags;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.difficulty,
    required this.tags,
  });
}

/// Filter chips row

class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterRow({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      'All',
      'Mindfulness',
      'Movement',
      'Nutrition',
      'Sleep',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (f) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: selected == f,
              onSelected: (_) => onChanged(f),
              selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
              labelStyle: TextStyle(
                color: selected == f
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade800,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

/// Section title

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Top pick big card

class _TopPickCard extends StatelessWidget {
  final ContentItem item;

  const _TopPickCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(item.type);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Top pick for today',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFF4CAF50), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _MetaRow(item: item),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting: ${item.title} (demo only)'),
                    ),
                  );
                },
                child: const Text('Start now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Regular content card

class _ContentCard extends StatelessWidget {
  final ContentItem item;
  final bool dense;
  final bool isSaved;

  const _ContentCard({
    required this.item,
    this.dense = false,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(item.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF4CAF50), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!dense) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  _MetaRow(item: item),
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () {
                final message = isSaved
                    ? 'Already in your saved list.'
                    : 'Saved for later (demo).';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                size: 22,
                color: isSaved ? const Color(0xFF4CAF50) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Metadata row (type • duration • difficulty)

class _MetaRow extends StatelessWidget {
  final ContentItem item;

  const _MetaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 11,
      color: Colors.grey.shade700,
    );

    return Row(
      children: [
        Icon(
          _iconForType(item.type),
          size: 14,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 4),
        Text(item.type, style: style),
        const SizedBox(width: 10),
        const Icon(Icons.schedule, size: 14),
        const SizedBox(width: 2),
        Text('${item.durationMinutes} min', style: style),
        const SizedBox(width: 10),
        const Icon(Icons.leaderboard, size: 14),
        const SizedBox(width: 2),
        Text(item.difficulty, style: style),
      ],
    );
  }
}

/// Empty state widget

class _EmptyState extends StatelessWidget {
  final VoidCallback onGoToTracker;

  const _EmptyState({required this.onGoToTracker});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'No recommendations yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Log today in the Tracker and we’ll start tailoring this page to you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onGoToTracker,
              icon: const Icon(Icons.favorite),
              label: const Text('Go to Tracker'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper: icon based on type

IconData _iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'mindfulness':
      return Icons.self_improvement;
    case 'movement':
      return Icons.fitness_center;
    case 'nutrition':
      return Icons.restaurant;
    case 'sleep':
      return Icons.bedtime;
    default:
      return Icons.auto_awesome;
  }
}
