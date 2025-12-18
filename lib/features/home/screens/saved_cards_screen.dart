import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'card_detail_screen.dart';

class SavedCardsScreen extends StatelessWidget {
  const SavedCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Saved Cards')),
        body: Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please log in to view saved cards.')),
              );
            },
            child: const Text('Log in to view saved cards'),
          ),
        ),
      );
    }

    final savedCardsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savedCards')
        .orderBy('savedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Cards')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: savedCardsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load saved cards.'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No saved cards yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final cardId = doc.id;

              return _SavedCardTile(cardId: cardId);
            },
          );
        },
      ),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    final cardRef =
        FirebaseFirestore.instance.collection('cards').doc(cardId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: cardRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const ListTile(
            title: Text('Loading...'),
          );
        }

        final data = snapshot.data?.data();
        final title = (data?['title'] ?? 'Healing card').toString();
        final quote = (data?['quote'] ?? '').toString();

        return ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text(title),
          subtitle: quote.isEmpty ? null : Text(quote, maxLines: 2),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardDetailScreen(cardId: cardId),
              ),
            );
          },
        );
      },
    );
  }
}
