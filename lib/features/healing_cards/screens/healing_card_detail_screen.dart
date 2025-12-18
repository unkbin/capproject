import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/healing_card.dart';

class HealingCardDetailScreen extends StatelessWidget {
  const HealingCardDetailScreen({
    super.key,
    required this.card,
    this.fallbackWebUrl,
  });

  final HealingCard card;
  final String? fallbackWebUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final webLink =
        card.webUrl.isNotEmpty ? card.webUrl : (fallbackWebUrl ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(card.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Healing Card #${card.cardNumber}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            card.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          if (card.quote.trim().isNotEmpty)
            _QuoteBlock(text: card.quote),
          if (card.quote.trim().isNotEmpty) const SizedBox(height: 18),
          if (card.appText.trim().isNotEmpty) ...[
            Text(
              card.appText,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 22),
          ],
          if (webLink.isNotEmpty)
            FilledButton.icon(
              onPressed: () => _launch(webLink, context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open web link'),
            ),
        ],
      ),
    );
  }

  Future<void> _launch(String url, BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
