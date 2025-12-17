import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'recipe_detail_screen.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  static const String _placeholderAsset = 'assets/recipes/placeholder.jpg';

  bool _showAllRecipes = false;

  // Healing cards (you can replace with Firestore later)
  final List<ContentItem> _healingCards = [
    ContentItem(
      id: 'breath_5',
      title: 'Pause and breathe',
      description: 'A short reset to calm your body.',
      type: 'Mindfulness',
      durationMinutes: 5,
      difficulty: 'Beginner',
      tags: ['stress', 'short', 'anytime'],
    ),
    ContentItem(
      id: 'body_scan_10',
      title: 'Body scan for sleep',
      description: 'Let your muscles soften before bed.',
      type: 'Sleep',
      durationMinutes: 10,
      difficulty: 'Easy',
      tags: ['sleep', 'evening', 'relax'],
    ),
    ContentItem(
      id: 'gratitude_3',
      title: 'Gratitude pause',
      description: 'End the day with a small reflection.',
      type: 'Mindfulness',
      durationMinutes: 3,
      difficulty: 'Beginner',
      tags: ['short', 'evening'],
    ),
  ];

  bool _preferRecipeNow() {
    final h = DateTime.now().hour;

    // Morning: 5am–11:59am → recipes
    if (h >= 5 && h < 12) return true;

    // Evening/Night: 6pm–4:59am → healing
    if (h >= 18 || h < 5) return false;

    // Afternoon: recipes (you can change later)
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final preferRecipe = _preferRecipeNow();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _Header(),
        const SizedBox(height: 16),

        // =====================
        // SMART HERO
        // =====================
        if (preferRecipe)
          _SmartRecipeHero(
            placeholderAsset: _placeholderAsset,
            onOpenRecipe: (data) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(data: data),
                ),
              );
            },
          )
        else
          _SmartHealingHero(
            item: _healingCards.first,
            onStart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting: ${_healingCards.first.title} (demo)'),
                ),
              );
            },
          ),

        const SizedBox(height: 20),

        // =====================
        // NOURISH (Recipes)
        // =====================
        const _SectionTitle('Nourish'),
        const SizedBox(height: 8),
        _RecipeCarousel(
          placeholderAsset: _placeholderAsset,
          showAll: _showAllRecipes,
          onToggleShowAll: () =>
              setState(() => _showAllRecipes = !_showAllRecipes),
          onOpenRecipe: (data) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(data: data),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // =====================
        // RESTORE (Healing cards)
        // =====================
        const _SectionTitle('Restore'),
        const SizedBox(height: 8),
        for (final item in _healingCards)
          _HealingCardTile(
            item: item,
            onStart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Starting: ${item.title} (demo)')),
              );
            },
          ),
      ],
    );
  }
}

/// --------------------
/// HEADER
/// --------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A calmer plan for your day.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

/// --------------------
/// SECTION TITLE
/// --------------------
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

/// --------------------
/// HERO BASE CARD
/// --------------------
class _HeroFocusCard extends StatelessWidget {
  final String title;
  final String headline;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HeroFocusCard({
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D32), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      headline,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
      ),
    );
  }
}

/// --------------------
/// SMART HERO: RECIPE
/// --------------------
class _SmartRecipeHero extends StatelessWidget {
  final String placeholderAsset;
  final ValueChanged<Map<String, dynamic>> onOpenRecipe;

  const _SmartRecipeHero({
    required this.placeholderAsset,
    required this.onOpenRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .orderBy('title')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _HeroFocusCard(
            title: 'Today’s focus',
            headline: 'Make something simple',
            subtitle: 'Add recipes to see a daily pick here.',
            icon: Icons.restaurant,
            onTap: () {},
          );
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '') as String;
        final minutes = data['minutes'] ?? 0;

        final imageAsset = (data['imageAsset'] as String?) ?? '';
        final safeImage = imageAsset.isNotEmpty ? imageAsset : placeholderAsset;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onOpenRecipe(data),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.asset(
                    safeImage,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        placeholderAsset,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
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
                              'TODAY’S RECIPE',
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
                              '$minutes min • Tap to view',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
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
      },
    );
  }
}

/// --------------------
/// SMART HERO: HEALING
/// --------------------
class _SmartHealingHero extends StatelessWidget {
  final ContentItem item;
  final VoidCallback onStart;

  const _SmartHealingHero({
    required this.item,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return _HeroFocusCard(
      title: 'Tonight’s reset',
      headline: item.title,
      subtitle: '${item.durationMinutes} min • ${item.description}',
      icon: Icons.self_improvement,
      onTap: onStart,
    );
  }
}

/// --------------------
/// RECIPES CAROUSEL
/// --------------------
class _RecipeCarousel extends StatelessWidget {
  final String placeholderAsset;
  final bool showAll;
  final VoidCallback onToggleShowAll;
  final ValueChanged<Map<String, dynamic>> onOpenRecipe;

  const _RecipeCarousel({
    required this.placeholderAsset,
    required this.showAll,
    required this.onToggleShowAll,
    required this.onOpenRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final recipeStream = FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('title')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: recipeStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Failed to load recipes.');
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text('No recipes yet.');

        final visible = showAll ? docs : docs.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final data = visible[index].data() as Map<String, dynamic>;
                  return _RecipeMiniCard(
                    data: data,
                    placeholderAsset: placeholderAsset,
                    onTap: () => onOpenRecipe(data),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (docs.length > 5)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onToggleShowAll,
                  child: Text(showAll ? 'Show less recipes' : 'Show more recipes'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RecipeMiniCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String placeholderAsset;
  final VoidCallback onTap;

  const _RecipeMiniCard({
    required this.data,
    required this.placeholderAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? '') as String;
    final minutes = data['minutes'] ?? 0;
    final imageAsset = (data['imageAsset'] as String?) ?? '';
    final safeImage = imageAsset.isNotEmpty ? imageAsset : placeholderAsset;

    return SizedBox(
      width: 170,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  safeImage,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      placeholderAsset,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$minutes min',
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// HEALING CARD TILE
/// --------------------
class _HealingCardTile extends StatelessWidget {
  final ContentItem item;
  final VoidCallback onStart;

  const _HealingCardTile({
    required this.item,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(item.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32)),
        ),
        title: Text(item.title),
        subtitle: Text('${item.durationMinutes} min • ${item.description}'),
        trailing: FilledButton(
          onPressed: onStart,
          child: const Text('Start'),
        ),
      ),
    );
  }
}

/// --------------------
/// MODEL
/// --------------------
class ContentItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final int durationMinutes;
  final String difficulty;
  final List<String> tags;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.difficulty,
    required this.tags,
  });
}

IconData _iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'mindfulness':
      return Icons.self_improvement;
    case 'movement':
      return Icons.fitness_center;
    case 'nutrition':
      return Icons.restaurant;
    case 'sleep':
      return Icons.bedtime;
    default:
      return Icons.auto_awesome;
  }
}
