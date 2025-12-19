import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/recipe_asset_helper.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  final Map<String, dynamic> data;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? '';
    final minutes = data['minutes'] ?? 0;
    final servings = data['servings'] ?? 0;
    final imageAsset = normalizeRecipeAsset(data['imageAsset'] as String?);

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
            '$minutes min -> $servings servings',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),
          Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final item in ingredients)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('-> $item'),
            ),

          const SizedBox(height: 24),
          Text(
            'Directions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < directions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${i + 1}. ${directions[i]}'),
            ),

          if (notes != null) ...[
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            if (notes['servingSize'] != null)
              Text('Serving size: ${notes['servingSize']}'),

            if (notes['leftovers'] != null) ...[
              const SizedBox(height: 8),
              Text('Leftovers: ${notes['leftovers']}'),
            ],

            if (notes['options'] is List) ...[
              const SizedBox(height: 12),
              for (final option in notes['options'])
                Text('-> $option'),
            ],
          ],

          const SizedBox(height: 24),
          _SaveRecipeButton(recipeId: recipeId),
        ],
      ),
    );
  }
}

class _SaveRecipeButton extends StatelessWidget {
  const _SaveRecipeButton({required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to save recipes.')),
            );
          },
          icon: const Icon(Icons.login),
          label: const Text('Log in to save'),
        ),
      );
    }

    final savedDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savedRecipes')
        .doc(recipeId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: savedDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final isSaved = snapshot.data?.exists == true;
        final label = isSaved ? 'Saved' : 'Save for later';
        final icon = isSaved ? Icons.bookmark : Icons.bookmark_add;

        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              if (isSaved) {
                await _unsave(context, savedDoc);
              } else {
                await _save(context, savedDoc);
              }
            },
            icon: Icon(icon),
            label: Text(label),
          ),
        );
      },
    );
  }

  Future<void> _save(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      await ref.set({'savedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Could not save. Please try again.');
    }
  }

  Future<void> _unsave(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      await ref.delete();
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Could not remove saved recipe.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
