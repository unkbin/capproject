import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecipeDetailScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? '';
    final minutes = data['minutes'] ?? 0;
    final servings = data['servings'] ?? 0;
    final imageAsset = data['imageAsset'] as String?;

    final ingredients =
        (data['ingredients'] as List?)?.cast<String>() ?? [];

    final directions =
        (data['directions'] as List?)?.cast<String>() ?? [];

    final notes = data['notes'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (imageAsset != null && imageAsset.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 16),
          Text(
            "$minutes min • $servings servings",
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),
          Text(
            "Ingredients",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final item in ingredients)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text("• $item"),
            ),

          const SizedBox(height: 24),
          Text(
            "Directions",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < directions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text("${i + 1}. ${directions[i]}"),
            ),

          if (notes != null) ...[
            const SizedBox(height: 24),
            Text(
              "Notes",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            if (notes['servingSize'] != null)
              Text("Serving size: ${notes['servingSize']}"),

            if (notes['leftovers'] != null) ...[
              const SizedBox(height: 8),
              Text("Leftovers: ${notes['leftovers']}"),
            ],

            if (notes['options'] is List) ...[
              const SizedBox(height: 12),
              for (final option in notes['options'])
                Text("• $option"),
            ],
          ],
        ],
      ),
    );
  }
}
