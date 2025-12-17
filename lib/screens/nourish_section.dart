import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_detail_screen.dart';



class NourishSection extends StatelessWidget {
  const NourishSection({
    super.key,
    required this.placeholderAsset,
    required this.showAll,
    required this.onToggleShowAll,
  });

  final String placeholderAsset;
  final bool showAll;
  final VoidCallback onToggleShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nourish',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _RecipeCarousel(
          placeholderAsset: placeholderAsset,
          showAll: showAll,
          onToggleShowAll: onToggleShowAll,
          onOpenRecipe: (data) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(data: data),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Paste your _RecipeCarousel + _RecipeMiniCard here (unchanged)
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
