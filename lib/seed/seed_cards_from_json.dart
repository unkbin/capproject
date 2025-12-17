import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Seeds cards from assets/cards/cards_seed.json into Firestore collection "cards".
/// Safe to run multiple times: it skips docs that already exist.
Future<void> seedCardsFromJson() async {
  final firestore = FirebaseFirestore.instance;

  final raw = await rootBundle.loadString('assets/cards/cards_seed.json');
  final List<dynamic> list = jsonDecode(raw);

  for (final item in list) {
    final map = Map<String, dynamic>.from(item as Map);

    final id = (map['id'] ?? '').toString().trim();
    if (id.isEmpty) continue;

    // Use list fields (cleaner for the app UI)
    final biomedicalPoints = (map['biomedicalPointsList'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    final neurospicyNotes = (map['neurospicyNotesList'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    final resources = (map['resourcesList'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    // Basic fields
    final data = <String, dynamic>{
      'title': (map['title'] ?? '').toString(),
      'quote': (map['quote'] ?? '').toString(),
      'appText': (map['appText'] ?? '').toString(),
      'weblink': (map['weblink'] ?? '').toString(),
      'webContent': (map['webContent'] ?? '').toString(),
      'biomedicalPoints': biomedicalPoints,
      'neurospicyNotes': neurospicyNotes,
      'resources': resources,

      // Optional fields (you can edit later in Firestore)
      'featured': false,
      'featuredRank': 999,
      'category': 'Healing',
      'minutes': 5,
      'tags': <String>[],
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = firestore.collection('cards').doc(id);
    final snap = await docRef.get();
    if (snap.exists) continue;

    await docRef.set(data);
  }
}
