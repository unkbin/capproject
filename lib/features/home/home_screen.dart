import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/all_recipes_screen.dart';
import 'widgets/healing_cards_all_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onGoToTab,
  });

  /// Switch bottom nav tab (do NOT push screens for tabs)
  final void Function(int index) onGoToTab;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TopRow(
          title: 'Synergy Holistic Health',
          onMenuTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu coming soon')),
            );
          },
        ),
        const SizedBox(height: 16),

        _UserGreeting(greetingText: _greeting()),
        const SizedBox(height: 18),

        _TodayFocusCard(
          title: 'Today’s focus',
          headline: 'One gentle step',
          subtitle: 'Pick a recipe or a healing card that fits your energy.',
          onTap: () => onGoToTab(1), // For You tab
        ),
        const SizedBox(height: 18),

        Text(
          'Quick actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        _QuickActionsGrid(
          actions: [
            _QuickAction(
              icon: Icons.auto_awesome,
              label: 'For You',
              onTap: () => onGoToTab(1),
            ),
            _QuickAction(
              icon: Icons.spa_outlined,
              label: 'Healing Cards',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HealingCardsAllScreen()),
                );
              },
            ),
            _QuickAction(
              icon: Icons.restaurant,
              label: 'Recipes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllRecipesScreen()),
                );
              },
            ),
            _QuickAction(
              icon: Icons.favorite_border,
              label: 'Tracker',
              onTap: () => onGoToTab(2),
            ),
            _QuickAction(
              icon: Icons.calendar_month,
              label: 'Bookings',
              onTap: () => onGoToTab(3),
            ),
            _QuickAction(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () => onGoToTab(4),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Text(
          'Suggested for now',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        _SuggestionTile(
          icon: Icons.spa_outlined,
          title: 'Start a healing card',
          subtitle: 'A 5 minute reset to settle your body.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealingCardsAllScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        _SuggestionTile(
          icon: Icons.restaurant,
          title: 'Make something simple',
          subtitle: 'Short recipes when energy is low.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllRecipesScreen()),
            );
          },
        ),
      ],
    );
  }
}

/// --------------------
/// TOP ROW
/// --------------------
class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.title,
    required this.onMenuTap,
  });

  final String title;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: onMenuTap,
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
        ),
      ],
    );
  }
}

/// --------------------
/// USER GREETING (Firestore user name)
/// --------------------
class _UserGreeting extends StatelessWidget {
  const _UserGreeting({
    required this.greetingText,
  });

  final String greetingText;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Text(
        '$greetingText.',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final name = (data?['name'] as String?)?.trim();

        final firstName =
        (name == null || name.isEmpty) ? 'there' : name.split(' ').first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greetingText, $firstName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What would help most today?',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        );
      },
    );
  }
}

/// --------------------
/// TODAY FOCUS CARD
/// --------------------
class _TodayFocusCard extends StatelessWidget {
  const _TodayFocusCard({
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String headline;
  final String subtitle;
  final VoidCallback onTap;

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
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2E7D32),
                  size: 26,
                ),
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
                        fontWeight: FontWeight.w800,
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
/// QUICK ACTIONS GRID
/// --------------------
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final a = actions[index];
        return _QuickActionTile(action: a);
      },
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 24),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// SUGGESTION TILE
/// --------------------
class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32)),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
