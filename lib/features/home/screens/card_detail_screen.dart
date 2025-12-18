import 'package:flutter/material.dart';

class CardDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const CardDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? '') as String;
    final quote = (data['quote'] ?? '') as String;
    final appText = (data['appText'] ?? '') as String;

    final biomedical = _stringList(data['biomedicalPoints']);
    final neurospicy = _stringList(data['neurospicyNotes']);
    final resources = _stringList(data['resources']);

    final weblink = (data['weblink'] ?? '') as String;
    final webContent = (data['webContent'] ?? '') as String;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (quote.trim().isNotEmpty) ...[
            _QuoteCard(text: quote),
            const SizedBox(height: 14),
          ],

          if (appText.trim().isNotEmpty) ...[
            const _SectionTitle('What this is'),
            const SizedBox(height: 6),
            Text(
              appText,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 18),
          ],

          if (biomedical.isNotEmpty) ...[
            const _SectionTitle('Biomedical points'),
            const SizedBox(height: 8),
            _Bullets(items: biomedical),
            const SizedBox(height: 18),
          ],

          if (neurospicy.isNotEmpty) ...[
            const _SectionTitle('Neurospicy notes'),
            const SizedBox(height: 8),
            _Bullets(items: neurospicy),
            const SizedBox(height: 18),
          ],

          if (resources.isNotEmpty) ...[
            const _SectionTitle('Try this'),
            const SizedBox(height: 8),
            _Bullets(items: resources),
            const SizedBox(height: 18),
          ],

          if (webContent.trim().isNotEmpty) ...[
            const _SectionTitle('More context'),
            const SizedBox(height: 6),
            Text(
              webContent,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 18),
          ],

          if (weblink.trim().isNotEmpty) ...[
            const _SectionTitle('Link'),
            const SizedBox(height: 6),
            _LinkChip(text: weblink),
            const SizedBox(height: 22),
          ],

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved (demo)')),
                );
              },
              icon: const Icon(Icons.bookmark_add),
              label: const Text('Save for later'),
            ),
          ),
        ],
      ),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    return [];
  }
}

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

class _QuoteCard extends StatelessWidget {
  final String text;
  const _QuoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  const _Bullets({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  s,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String text;
  const _LinkChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ActionChip(
        label: Text(text, overflow: TextOverflow.ellipsis),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening links comes next (url_launcher).'),
            ),
          );
        },
      ),
    );
  }
}
