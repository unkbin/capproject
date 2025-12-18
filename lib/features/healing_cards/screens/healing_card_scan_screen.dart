import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/healing_card_service.dart';
import 'healing_card_lookup_screen.dart';

class HealingCardScanScreen extends StatefulWidget {
  const HealingCardScanScreen({super.key});

  @override
  State<HealingCardScanScreen> createState() => _HealingCardScanScreenState();
}

class _HealingCardScanScreenState extends State<HealingCardScanScreen> {
  late final MobileScannerController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    final raw = capture.barcodes
        .map((b) => b.rawValue?.trim())
        .firstWhere((value) => value != null && value.isNotEmpty, orElse: () => null);

    if (raw == null || raw.isEmpty) return;

    _handled = true;
    _controller.stop();

    final parsed = parseHealingCardFromScan(raw);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HealingCardLookupScreen(parsedResult: parsed),
      ),
    ).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _handled = false;
      });
      _controller.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Healing Card'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Align the QR code within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We will load the healing card automatically',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
