import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'recipe_detail_screen.dart';
import 'card_detail_screen.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  static const String _placeholderAsset = 'assets/recipes/placeholder.jpg';
  bool _showAllRecipes = false;

  bool _preferRecipeNow() {
    final h = DateTime.now().hour;

    if (h >= 5 && h < 12) return true; // morning
    if (h >= 18 || h < 5) return false; // night
    return true; // afternoon
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
          const _SmartCardHero(),

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
        // RESTORE (Cards from Firestore)
        // =====================
        const _SectionTitle('Restore'),
        const SizedBox(height: 8),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cards')
              .orderBy('updatedAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Failed to load cards.');
            }

            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Text('No cards yet.');
            }

            return Column(
              children: [
                for (final doc in docs)
                  _FirestoreHealingCardTile(
                    data: doc.data() as Map<String, dynamic>,
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All Cards screen is next'),
                        ),
                      );
                    },
                    child: const Text('Show more cards'),
                  ),
                ),
              ],
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
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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
/// SMART HERO: CARD (from Firestore)
/// --------------------
class _SmartCardHero extends StatelessWidget {
  const _SmartCardHero();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cards')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _HeroFocusCard(
            title: 'Tonight’s reset',
            headline: 'Take a small pause',
            subtitle: 'Add cards to see a nightly pick here.',
            icon: Icons.self_improvement,
            onTap: () {},
          );
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '') as String;
        final quote = (data['quote'] ?? '') as String;

        return _HeroFocusCard(
          title: 'Tonight’s reset',
          headline: title,
          subtitle: quote.isEmpty ? 'Tap to open' : quote,
          icon: Icons.self_improvement,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardDetailScreen(data: data),
              ),
            );
          },
        );
      },
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
                  child:
                  Text(showAll ? 'Show less recipes' : 'Show more recipes'),
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
/// FIRESTORE CARD TILE
/// --------------------
class _FirestoreHealingCardTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _FirestoreHealingCardTile({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? '') as String;
    final minutes = data['minutes'] ?? 5;
    final appText = (data['appText'] ?? '') as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardDetailScreen(data: data),
            ),
          );
        },
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.self_improvement,
            color: Color(0xFF2E7D32),
          ),
        ),
        title: Text(title),
        subtitle: Text('$minutes min • $appText'),
        trailing: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardDetailScreen(data: data),
              ),
            );
          },
          child: const Text('Start'),
        ),
      ),
    );
  }
}
