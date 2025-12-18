import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'card_detail_view.dart';

class CardDetailScreen extends StatelessWidget {
  final String? cardId;
  final String? qrCode;

  const CardDetailScreen({
    super.key,
    this.cardId,
    this.qrCode,
  }) : assert(cardId != null || qrCode != null);

  @override
  Widget build(BuildContext context) {
    final cards = FirebaseFirestore.instance.collection('cards');

    Future<DocumentSnapshot<Map<String, dynamic>>> load() async {
      if (cardId != null) {
        return cards.doc(cardId).get();
      }

      final q = await cards.where('qrCode', isEqualTo: qrCode).limit(1).get();
      if (q.docs.isEmpty) {
        throw StateError('Card not found for qrCode=$qrCode');
      }
      return q.docs.first;
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: load(),
      builder: (context, snapshot) {
        final doc = snapshot.data;
        final data = doc?.data();
        final title = (data?['title'] ?? 'Card').toString();

        Widget body;
        if (snapshot.connectionState == ConnectionState.waiting) {
          body = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || doc == null || data == null) {
          body = const Center(child: Text('Card not found'));
        } else {
          body = CardDetailView(
            cardId: doc.id,
            data: data,
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: body,
        );
      },
    );
  }
}
