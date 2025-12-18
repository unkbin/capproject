import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/recipe_detail_screen.dart';
import '../screens/card_detail_screen.dart';
import '../../../core/utils/recipe_asset_helper.dart';

class SmartHeroSection extends StatelessWidget {
  const SmartHeroSection({
    super.key,
    required this.preferRecipe,
    required this.placeholderAsset,
  });

  final bool preferRecipe;
  final String placeholderAsset;

  @override
  Widget build(BuildContext context) {
    if (preferRecipe) {
      return _SmartRecipeHero(
        placeholderAsset: placeholderAsset,
        onOpenRecipe: (data) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(data: data),
            ),
          );
        },
      );
    }
    return const _SmartCardHero();
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
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.10),
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
            title: "Today's focus",
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
        final safeImage = normalizeRecipeAsset(imageAsset);

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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
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
                              "TODAY'S RECIPE",
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
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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
/// SMART HERO: CARD
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
            title: "Tonight's reset",
            headline: 'Take a small pause',
            subtitle: 'Add cards to see a nightly pick here.',
            icon: Icons.self_improvement,
            onTap: () {},
          );
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '') as String;
        final quote = (data['quote'] ?? '') as String;

        return _HeroFocusCard(
          title: "Tonight's reset",
          headline: title,
          subtitle: quote.isEmpty ? 'Tap to open' : quote,
          icon: Icons.self_improvement,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardDetailScreen(cardId: doc.id),
              ),
            );
          },
        );
      },
    );
  }
}
