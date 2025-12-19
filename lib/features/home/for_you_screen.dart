import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'for_you_header.dart';
import 'widgets/smart_hero_section.dart';
import 'widgets/healing_cards_section.dart'; // for HealingCardPreviewCard
import 'widgets/healing_cards_all_screen.dart';

import '../../core/utils/recipe_asset_helper.dart';

import 'screens/all_recipes_screen.dart';
import 'screens/daily_checkin_screen.dart';
import 'screens/card_detail_screen.dart';
import 'screens/recipe_detail_screen.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  static const String placeholderAsset = recipePlaceholderAsset;
  late Future<_ForYouData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadForYouData();
  }

  Future<_ForYouData> _loadForYouData() async {
    final user = FirebaseAuth.instance.currentUser;

    _CheckInData? checkIn;
    if (user != null) {
      checkIn = await _loadLatestCheckIn(user.uid);
    }

    final now = DateTime.now();
    final dailySeed = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );
    final random = Random(dailySeed);
    final shownIds = <String>{};

    final cards = await _fetchDocs(
      collection: 'cards',
      orderByField: 'updatedAt',
      descending: true,
      limit: 50,
    );

    final recipes = await _fetchDocs(
      collection: 'recipes',
      orderByField: 'title',
      limit: 50,
    );

    final cardSuggestions = _rankCards(cards, checkIn, random, shownIds);
    final recipeSuggestions = _rankRecipes(recipes, checkIn, random, shownIds);

    return _ForYouData(
      checkIn: checkIn,
      cardSuggestions: cardSuggestions,
      recipeSuggestions: recipeSuggestions,
    );
  }

  Future<_CheckInData?> _loadLatestCheckIn(String uid) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('checkins');

      final todayId = _todayId();
      final todayDoc = await ref.doc(todayId).get();
      DocumentSnapshot<Map<String, dynamic>>? doc;

      if (todayDoc.exists) {
        doc = todayDoc;
      } else {
        final latest =
        await ref.orderBy('createdAt', descending: true).limit(1).get();
        if (latest.docs.isNotEmpty) {
          doc = latest.docs.first;
        }
      }

      final data = doc?.data();
      if (data == null) return null;

      final energy = (data['energy'] as String?)?.toLowerCase();
      final brain = (data['brain'] as String?)?.toLowerCase();
      final pain = (data['pain'] as String?)?.toLowerCase();
      if (energy == null || brain == null || pain == null) return null;

      return _CheckInData(energy: energy, brain: brain, pain: pain);
    } catch (_) {
      return null;
    }
  }

  String _todayId() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  Future<List<_DocData>> _fetchDocs({
    required String collection,
    required String orderByField,
    bool descending = false,
    int limit = 40,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
      FirebaseFirestore.instance.collection(collection);

      query = query.orderBy(orderByField, descending: descending).limit(limit);
      final snap = await query.get();

      return snap.docs.map((d) => _DocData(id: d.id, data: d.data())).toList();
    } catch (_) {
      return const [];
    }
  }

  List<_DocData> _rankCards(
      List<_DocData> cards,
      _CheckInData? checkIn,
      Random random,
      Set<String> shownIds,
      ) {
    if (cards.isEmpty) return const [];

    final scored = <_ScoredDoc>[];
    for (var i = 0; i < cards.length; i++) {
      double score = (cards.length - i).toDouble(); // recency
      final data = cards[i].data;

      final minutes = _readMinutes(data);
      final tags = _stringList(data['tags']);
      final textLength = _textLength(data);
      final combinedText = _combinedText(data);

      if (checkIn != null) {
        if (checkIn.energy == 'low') {
          if (minutes > 0 && minutes <= 5) {
            score += 30;
          } else if (minutes > 0 && minutes <= 10) {
            score += 12;
          } else {
            score -= 6;
          }
        }

        if (checkIn.brain == 'foggy') {
          if (_hasAnyTag(tags, const ['step-by-step', 'steps', 'step_by_step'])) {
            score += 15;
          } else if (textLength > 0) {
            if (textLength <= 240) {
              score += 8;
            } else if (textLength <= 420) {
              score += 3;
            } else {
              score -= 4;
            }
          }
        }

        if (checkIn.pain == 'high') {
          if (_hasAnyTag(tags, const ['nervous_system', 'pacing', 'rest'])) {
            score += 18;
          } else if (_hasKeywords(combinedText,
              const ['rest', 'pause', 'nervous', 'pacing', 'gentle'])) {
            score += 10;
          }
        }
      }

      scored.add(_ScoredDoc(doc: cards[i], score: score));
    }

    return _pickForToday(scored, random, shownIds: shownIds);
  }

  List<_DocData> _rankRecipes(
      List<_DocData> recipes,
      _CheckInData? checkIn,
      Random random,
      Set<String> shownIds,
      ) {
    if (recipes.isEmpty) return const [];

    final scored = <_ScoredDoc>[];
    for (var i = 0; i < recipes.length; i++) {
      double score = (recipes.length - i).toDouble();
      final data = recipes[i].data;

      final minutes = _readMinutes(data);
      final tags = _stringList(data['tags']);
      final steps = _stepsCount(data);
      final combinedText = _combinedText(data);

      if (checkIn != null) {
        if (checkIn.energy == 'low') {
          if (minutes > 0 && minutes <= 10) {
            score += 16;
            if (minutes <= 5) score += 8;
          } else if (minutes > 20) {
            score -= 6;
          }
        }

        if (checkIn.brain == 'foggy') {
          if (_hasAnyTag(tags, const ['step-by-step', 'steps', 'simple'])) {
            score += 10;
          } else if (steps > 0) {
            if (steps <= 4) {
              score += 6;
            } else if (steps <= 7) {
              score += 2;
            } else {
              score -= 4;
            }
          }
        }

        if (checkIn.pain == 'high') {
          if (_hasAnyTag(tags, const ['nervous_system', 'pacing', 'rest'])) {
            score += 12;
          } else if (_hasKeywords(combinedText,
              const ['rest', 'pause', 'nervous', 'pacing', 'gentle'])) {
            score += 8;
          }
        }
      }

      scored.add(_ScoredDoc(doc: recipes[i], score: score));
    }

    return _pickForToday(scored, random, shownIds: shownIds);
  }

  List<_DocData> _pickForToday(
      List<_ScoredDoc> scored,
      Random random, {
        required Set<String> shownIds,
        int take = 3,
        int shuffleTop = 12,
      }) {
    if (scored.isEmpty) return const [];

    scored.sort((a, b) => b.score.compareTo(a.score));
    final topSlice = scored.take(min(shuffleTop, scored.length)).toList();
    topSlice.shuffle(random);

    final ordered = [...topSlice, ...scored.skip(topSlice.length)];
    final picks = <_DocData>[];

    for (final entry in ordered) {
      if (shownIds.contains(entry.doc.id)) continue;
      shownIds.add(entry.doc.id);
      picks.add(entry.doc);
      if (picks.length >= take) break;
    }

    return picks;
  }

  int _readMinutes(Map<String, dynamic> data) {
    final m1 = data['minutes'];
    if (m1 is int) return m1;
    if (m1 is num) return m1.round();

    final m2 = data['duration'];
    if (m2 is int) return m2;
    if (m2 is num) return m2.round();

    return -1;
  }

  int _stepsCount(Map<String, dynamic> data) {
    final dirs = data['directions'];
    if (dirs is List) return dirs.length;
    return 0;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().toLowerCase().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  bool _hasAnyTag(List<String> tags, List<String> desired) {
    final set = tags.toSet();
    for (final target in desired) {
      if (set.contains(target)) return true;
    }
    return false;
  }

  String _combinedText(Map<String, dynamic> data) {
    final parts = [
      data['title'],
      data['quote'],
      data['appText'],
      data['preview'],
      data['description'],
    ];
    return parts
        .whereType<String>()
        .map((s) => s.toLowerCase())
        .where((s) => s.isNotEmpty)
        .join(' ');
  }

  bool _hasKeywords(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    for (final word in keywords) {
      if (lower.contains(word)) return true;
    }
    return false;
  }

  int _textLength(Map<String, dynamic> data) {
    final textCandidates = [
      data['appText'],
      data['preview'],
      data['quote'],
    ];
    for (final t in textCandidates) {
      if (t is String && t.trim().isNotEmpty) {
        return t.length;
      }
    }
    return 0;
  }

  String? _reasonLabel(_CheckInData? checkIn) {
    if (checkIn == null) return null;

    if (checkIn.pain == 'high') return 'Because you chose: High pain';
    if (checkIn.energy == 'low') return 'Because you chose: Low energy';
    if (checkIn.brain == 'foggy') return 'Because you chose: Brain fog';

    if (checkIn.energy.isNotEmpty) {
      return 'Because you chose: ${_titleCase(checkIn.energy)} energy';
    }
    if (checkIn.brain.isNotEmpty) {
      return 'Because you chose: ${_titleCase(checkIn.brain)} focus';
    }
    if (checkIn.pain.isNotEmpty) {
      return 'Because you chose: ${_titleCase(checkIn.pain)} pain';
    }

    return null;
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadForYouData();
    });
    await _future;
  }

  Future<void> _openCheckIn() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyCheckInScreen()),
    );

    if (updated == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<_ForYouData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final loading = snapshot.connectionState == ConnectionState.waiting;

        final reasonLabel = _reasonLabel(data?.checkIn);
        final recipes = data?.recipeSuggestions ?? const <_DocData>[];
        final cards = data?.cardSuggestions ?? const <_DocData>[];

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ForYouHeader(),
              const SizedBox(height: 12),

              // ✅ KEEP TODAY SECTION AS-IS
              Row(
                children: [
                  Expanded(
                    child: _CheckInSummary(
                      checkIn: data?.checkIn,
                      loading: loading,
                      isLoggedIn: user != null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _openCheckIn,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Daily check-in'),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Text(
                'Suggested for you',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ✅ HERO RECIPE FIRST (forced)
              SmartHeroSection(
                preferRecipe: true,
                placeholderAsset: placeholderAsset,
              ),

              const SizedBox(height: 16),

              // ✅ 3 RECIPES + SHOW MORE
              _RecipesTop3(
                loading: loading,
                recipes: recipes,
                reasonLabel: reasonLabel,
                placeholderAsset: placeholderAsset,
              ),

              const SizedBox(height: 22),

              // ✅ HERO HEALING CARD + 3 MORE + SHOW MORE
              _HealingCardsBlock(
                loading: loading,
                cards: cards,
                reasonLabel: reasonLabel,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecipesTop3 extends StatelessWidget {
  const _RecipesTop3({
    required this.loading,
    required this.recipes,
    required this.reasonLabel,
    required this.placeholderAsset,
  });

  final bool loading;
  final List<_DocData> recipes;
  final String? reasonLabel;
  final String placeholderAsset;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: LinearProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipes',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),

        if (recipes.isEmpty)
          const Text('Add recipes to see suggestions here.')
        else ...[
          for (final doc in recipes.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecipeSuggestionCard(
                id: doc.id,
                data: doc.data,
                reasonLabel: reasonLabel,
                placeholderAsset: placeholderAsset,
              ),
            ),
        ],

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllRecipesScreen()),
              );
            },
            child: const Text('Show more recipes'),
          ),
        ),
      ],
    );
  }
}

class _HealingCardsBlock extends StatelessWidget {
  const _HealingCardsBlock({
    required this.loading,
    required this.cards,
    required this.reasonLabel,
  });

  final bool loading;
  final List<_DocData> cards;
  final String? reasonLabel;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: LinearProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TodayHealingCardHero(),
        const SizedBox(height: 14),

        Text(
          'Healing cards',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),

        if (cards.isEmpty)
          const Text('Add healing cards to see suggestions here.')
        else ...[
          for (final doc in cards.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HealingCardPreviewCard(
                data: doc.data,
                reasonLabel: reasonLabel,
                onStart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardDetailScreen(cardId: doc.id),
                    ),
                  );
                },
              ),
            ),
        ],

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealingCardsAllScreen()),
              );
            },
            child: const Text('Show more healing cards'),
          ),
        ),
      ],
    );
  }
}

class _TodayHealingCardHero extends StatefulWidget {
  const _TodayHealingCardHero();

  @override
  State<_TodayHealingCardHero> createState() => _TodayHealingCardHeroState();
}

class _TodayHealingCardHeroState extends State<_TodayHealingCardHero> {
  late final Future<_DocData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadTodayCard();
  }

  Future<_DocData?> _loadTodayCard() async {
    final excludeIds = await _fetchTopCardIds();
    final cards = await _fetchCards();
    if (cards.isEmpty) return null;

    final filtered = cards.where((c) => !excludeIds.contains(c.id)).toList();
    final pool = filtered.isNotEmpty ? filtered : cards;

    final index = _dailyIndex(pool.length);
    return pool[index];
  }

  Future<List<String>> _fetchTopCardIds() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('cards')
          .orderBy('updatedAt', descending: true)
          .limit(3)
          .get();
      return snap.docs.map((doc) => doc.id).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<_DocData>> _fetchCards() async {
    final cardsRef = FirebaseFirestore.instance.collection('cards');
    try {
      final snap = await cardsRef
          .orderBy('updatedAt', descending: true)
          .limit(30)
          .get();
      return snap.docs.map((d) => _DocData(id: d.id, data: d.data())).toList();
    } catch (_) {
      try {
        final snap = await cardsRef.orderBy('title').limit(30).get();
        return snap.docs.map((d) => _DocData(id: d.id, data: d.data())).toList();
      } catch (_) {
        return const [];
      }
    }
  }

  int _dailyIndex(int length) {
    final now = DateTime.now();
    final seed = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );
    return Random(seed).nextInt(length);
  }

  int _readMinutes(Map<String, dynamic> data) {
    final m1 = data['minutes'];
    if (m1 is int) return m1;
    if (m1 is num) return m1.round();

    final m2 = data['duration'];
    if (m2 is int) return m2;
    if (m2 is num) return m2.round();

    return 5;
  }

  String _readPreview(Map<String, dynamic> data) {
    final p = data['preview'];
    if (p is String && p.trim().isNotEmpty) return p.trim();

    final a = data['appText'];
    if (a is String && a.trim().isNotEmpty) return a.trim();

    final q = data['quote'];
    if (q is String && q.trim().isNotEmpty) return q.trim();

    return 'Tap to open';
  }

  Widget _buildHeroCard(BuildContext context, _DocData doc) {
    final theme = Theme.of(context);
    final data = doc.data;

    final title = (data['title'] ?? '') as String;
    final minutes = _readMinutes(data);
    final preview = _readPreview(data);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CardDetailScreen(cardId: doc.id)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.18),
                      theme.colorScheme.primary.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.spa_outlined,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S HEALING CARD",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$minutes min -> Tap to view',
                          style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, {required String message}) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              height: 170,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.spa_outlined,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TODAY'S HEALING CARD",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DocData?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildEmptyCard(context, message: "Loading today's pick...");
        }

        final doc = snapshot.data;
        if (doc == null) {
          return _buildEmptyCard(
            context,
            message: 'Add cards to see a daily pick here.',
          );
        }

        return _buildHeroCard(context, doc);
      },
    );
  }
}

class _ForYouData {
  const _ForYouData({
    required this.checkIn,
    required this.cardSuggestions,
    required this.recipeSuggestions,
  });

  final _CheckInData? checkIn;
  final List<_DocData> cardSuggestions;
  final List<_DocData> recipeSuggestions;
}

class _CheckInData {
  const _CheckInData({
    required this.energy,
    required this.brain,
    required this.pain,
  });

  final String energy;
  final String brain;
  final String pain;

  String summary() {
    return 'Energy: ${_label(energy)} \u00b7 Brain: ${_label(brain)} \u00b7 Pain: ${_label(pain)}';
  }

  String _label(String v) {
    if (v.isEmpty) return v;
    return v[0].toUpperCase() + v.substring(1);
  }
}

class _DocData {
  const _DocData({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

class _ScoredDoc {
  const _ScoredDoc({required this.doc, required this.score});

  final _DocData doc;
  final double score;
}

class _CheckInSummary extends StatelessWidget {
  const _CheckInSummary({
    required this.checkIn,
    required this.loading,
    required this.isLoggedIn,
  });

  final _CheckInData? checkIn;
  final bool loading;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: loading
                ? const LinearProgressIndicator(minHeight: 6)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest check-in',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _summaryText(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _summaryText() {
    if (checkIn != null) return checkIn!.summary();
    if (!isLoggedIn) return 'Log in and save a quick check-in.';
    return 'No check-in yet. Tap to save how you feel today.';
  }
}

class _RecipeSuggestionCard extends StatelessWidget {
  const _RecipeSuggestionCard({
    required this.id,
    required this.data,
    required this.reasonLabel,
    required this.placeholderAsset,
  });

  final String id;
  final Map<String, dynamic> data;
  final String? reasonLabel;
  final String placeholderAsset;

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? '') as String;
    final minutes = data['minutes'] ?? 0;
    final imageAsset = normalizeRecipeAsset(data['imageAsset'] as String?);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipeId: id, data: data),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.asset(
                imageAsset,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  placeholderAsset,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$minutes min',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    if (reasonLabel != null && reasonLabel!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        reasonLabel!,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
