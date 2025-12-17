import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'card_detail_screen.dart';



class HealingCardsSection extends StatelessWidget {
  const HealingCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Healing Cards',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Support for this moment',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cards')
              .orderBy('updatedAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('Failed to load healing cards.');
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text('No healing cards yet.');

            return Column(
              children: [
                for (final doc in docs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HealingCardPreviewCard(
                      data: doc.data() as Map<String, dynamic>,
                      onStart: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardDetailScreen(
                              data: doc.data() as Map<String, dynamic>,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All Healing Cards screen is next')),
                      );
                    },
                    child: const Text('Show more cards'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class HealingCardPreviewCard extends StatelessWidget {
  const HealingCardPreviewCard({
    super.key,
    required this.data,
    required this.onStart,
  });

  final Map<String, dynamic> data;
  final VoidCallback onStart;

  int _readMinutes(Map<String, dynamic> d) {
    final m1 = d['minutes'];
    if (m1 is int) return m1;
    final m2 = d['duration'];
    if (m2 is int) return m2;
    return 5;
  }

  String _readPreview(Map<String, dynamic> d) {
    final p = d['preview'];
    if (p is String && p.trim().isNotEmpty) return p.trim();
    final a = d['appText'];
    if (a is String && a.trim().isNotEmpty) return a.trim();
    final q = d['quote'];
    if (q is String && q.trim().isNotEmpty) return q.trim();
    return 'Tap to begin.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = (data['title'] ?? '') as String;
    final preview = _readPreview(data);
    final minutes = _readMinutes(data);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.spa_outlined, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Healing Card',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    '$minutes min',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Start'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
