import 'package:flutter/material.dart';

import 'for_you_header.dart';
import 'smart_hero_section.dart';
import 'nourish_section.dart';
import 'healing_cards_section.dart';


class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  static const String placeholderAsset = 'assets/recipes/placeholder.jpg';
  bool showAllRecipes = false;

  bool _preferRecipeNow() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return true;
    if (h >= 18 || h < 5) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final preferRecipe = _preferRecipeNow();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ForYouHeader(),
        const SizedBox(height: 16),

        SmartHeroSection(
          preferRecipe: preferRecipe,
          placeholderAsset: placeholderAsset,
        ),

        const SizedBox(height: 20),

        NourishSection(
          placeholderAsset: placeholderAsset,
          showAll: showAllRecipes,
          onToggleShowAll: () => setState(() => showAllRecipes = !showAllRecipes),
        ),

        const SizedBox(height: 24),

        const HealingCardsSection(),
      ],
    );
  }
}
