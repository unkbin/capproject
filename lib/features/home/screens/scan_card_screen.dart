import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../home/screens/card_detail_screen.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;

          final raw = capture.barcodes.isNotEmpty
              ? capture.barcodes.first.rawValue
              : null;

          if (raw == null || raw.trim().isEmpty) return;

          _handled = true;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CardDetailScreen(qrCode: raw.trim()),
            ),
          );
        },
      ),
    );
  }
}
