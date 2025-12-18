import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/healing_card.dart';
import '../services/healing_card_service.dart';
import 'healing_card_detail_screen.dart';

class HealingCardLookupScreen extends StatefulWidget {
  const HealingCardLookupScreen({
    super.key,
    required this.parsedResult,
    this.service,
  });

  final HealingCardScanParseResult parsedResult;
  final HealingCardService? service;

  @override
  State<HealingCardLookupScreen> createState() =>
      _HealingCardLookupScreenState();
}

class _HealingCardLookupScreenState extends State<HealingCardLookupScreen> {
  late final HealingCardService _service;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? HealingCardService();
    _load();
  }

  Future<void> _load() async {
    final cardId = widget.parsedResult.cardId;
    if (cardId == null || cardId.isEmpty) {
      setState(() {
        _error = 'Could not read a card from this QR code.';
        _loading = false;
      });
      return;
    }

    try {
      final card = await _service.fetchCardById(cardId);
      if (!mounted) return;
      _openDetail(card);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'We could not find that healing card right now.';
        _loading = false;
      });
    }
  }

  void _openDetail(HealingCard card) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HealingCardDetailScreen(
          card: card,
          fallbackWebUrl:
              widget.parsedResult.webUrl ?? widget.parsedResult.rawValue,
        ),
      ),
    );
  }

  Future<void> _openWebLink() async {
    final web = widget.parsedResult.webUrl ?? widget.parsedResult.rawValue;
    final uri = Uri.tryParse(web.trim());
    if (uri == null || (!uri.hasScheme)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid link')),
        );
      }
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healing Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Card not found.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Rescan'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _openWebLink,
                    child: const Text('Open web link'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.parsedResult.webUrl ?? widget.parsedResult.rawValue,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
