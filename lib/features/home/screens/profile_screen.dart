import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/screens/welcome_screen.dart';
import 'saved_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false; // demo-only, not wired to app theme

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Fallback if somehow we reach Profile while logged out
    if (user == null) {
      return Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
            );
          },
          child: const Text("You’re not logged in. Back to login"),
        ),
      );
    }

    final displayName = user.displayName ?? _nameFromEmail(user.email);
    final email = user.email ?? "No email set";
    final initials = _initialsFrom(displayName, email);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title + small logout icon
          Row(
            children: [
              Text(
                "Profile",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: "Log out",
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Log out"),
                      content: const Text(
                          "Are you sure you want to log out of Synergy Holistic Health?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Log out"),
                        ),
                      ],
                    ),
                  );

                  if (!mounted) return;

                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const WelcomeScreen()),
                          (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header card: avatar + name + email + edit button
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                    const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Edit profile coming soon."),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick stats row (demo values for now)
          Text(
            "Wellness snapshot",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              _StatChip(
                label: "Streak",
                value: "3 days",
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
              ),
              SizedBox(width: 8),
              _StatChip(
                label: "Sessions",
                value: "5 completed",
                icon: Icons.self_improvement,
                iconColor: Colors.deepPurple,
              ),
              SizedBox(width: 8),
              _StatChip(
                label: "Check-ins",
                value: "12 this month",
                icon: Icons.calendar_today,
                iconColor: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Wellness preferences section
          _SectionCard(
            title: "Wellness preferences",
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text("Saved"),
                subtitle: const Text("View your saved cards and recipes"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SavedScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text("Focus areas"),
                subtitle: const Text("Stress, sleep, movement"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Focus area editing coming soon."),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text("Reminder schedule"),
                subtitle: const Text("Daily, 8:00 PM"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reminder settings coming soon."),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.self_improvement_outlined),
                title: const Text("Daily check-in time"),
                subtitle: const Text("Flexible"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Check-in time editing coming soon."),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // App settings section
          _SectionCard(
            title: "App settings",
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text("Push notifications"),
                subtitle: const Text("Reminders and booking updates"),
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text("Dark mode (demo)"),
                subtitle: const Text("Visual preview only"),
                value: _darkMode,
                onChanged: (val) {
                  setState(() => _darkMode = val);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text("Export wellness data"),
                subtitle: const Text("Download a summary of your check-ins"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data export coming soon."),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account section with big logout button
          Text(
            "Account",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Log out",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Log out"),
                    content: const Text(
                        "Are you sure you want to log out of your account?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Log out"),
                      ),
                    ],
                  ),
                );

                if (!mounted) return;

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const WelcomeScreen()),
                        (route) => false,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return "Wellness member";
    return email.split("@").first;
  }

  String _initialsFrom(String? name, String? email) {
    final source = (name != null && name.trim().isNotEmpty)
        ? name
        : _nameFromEmail(email);
    final parts = source.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// Small reusable section card
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Chip-like stat widget
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
