import 'package:flutter/material.dart';
import 'service_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String selectedCategory = "All";

  final categories = [
    "All",
    "Mindfulness",
    "Coaching",
    "Nutrition",
    "Movement",
    "Sleep",
  ];

  final List<ServiceItem> services = [
    ServiceItem(
      id: "mindfulness_1",
      title: "Mindfulness Coaching",
      description: "Guided breathing, grounding and relaxation techniques.",
      category: "Mindfulness",
      duration: 30,
      image: "https://i.imgur.com/W1aU9bF.png",
    ),
    ServiceItem(
      id: "nutrition_1",
      title: "Nutrition Consultation",
      description: "Personalised food habits and wellness meal planning.",
      category: "Nutrition",
      duration: 45,
      image: "https://i.imgur.com/BPpF2cL.png",
    ),
    ServiceItem(
      id: "coaching_1",
      title: "Holistic Wellness Coaching",
      description: "Lifestyle support and personalised daily routines.",
      category: "Coaching",
      duration: 60,
      image: "https://i.imgur.com/KlUO4pN.png",
    ),
    ServiceItem(
      id: "movement_1",
      title: "Gentle Movement Session",
      description: "Low-impact movement and stretching for energy.",
      category: "Movement",
      duration: 20,
      image: "https://i.imgur.com/kHkHkNC.png",
    ),
    ServiceItem(
      id: "sleep_1",
      title: "Sleep Coaching",
      description: "Support creating a calm night routine.",
      category: "Sleep",
      duration: 40,
      image: "https://i.imgur.com/vB4j5FV.png",
    ),
  ];

  List<ServiceItem> get filteredServices {
    if (selectedCategory == "All") return services;
    return services.where((s) => s.category == selectedCategory).toList();
  }

  // Store confirmed bookings (simple in-memory list)
  final List<BookingItem> bookings = [];

  void onBookingConfirmed(BookingItem booking) {
    setState(() {
      bookings.add(booking);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BookingHero(),
          const SizedBox(height: 18),

          // Category chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((c) {
              final selected = c == selectedCategory;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                onSelected: (_) {
                  setState(() => selectedCategory = c);
                },
                selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Service list
          Text(
            "Available Services",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          for (final service in filteredServices)
            _ServiceCard(
              service: service,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);

                final booking = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(service: service),
                  ),
                );

                if (!mounted) return;

                if (booking != null) {
                  onBookingConfirmed(booking);
                  messenger.showSnackBar(
                    const SnackBar(content: Text("Booking confirmed!")),
                  );
                }
              },
            ),

          const SizedBox(height: 30),

          // Upcoming bookings
          if (bookings.isNotEmpty) ...[
            Text(
              "Upcoming Sessions",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            for (final booking in bookings)
              _BookingCard(booking: booking),
          ],
        ],
      ),
    );
  }
}

/// Data models
class ServiceItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final int duration;
  final String image;

  ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.image,
  });
}

class BookingItem {
  final ServiceItem service;
  final DateTime dateTime;

  BookingItem({required this.service, required this.dateTime});
}

/// UI Components
class _ServiceCard extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.network(
                    service.image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _CategoryPill(text: service.category),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _DurationPill(minutes: service.duration),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        "Flexible scheduling",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade600,
                      ),
                    ],
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

class _BookingCard extends StatelessWidget {
  final BookingItem booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final date = "${booking.dateTime.day}/${booking.dateTime.month}";
    final time =
        "${booking.dateTime.hour}:${booking.dateTime.minute.toString().padLeft(2, '0')}";

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.event_available, color: Color(0xFF4CAF50)),
        title: Text(booking.service.title),
        subtitle: Text("On $date at $time"),
      ),
    );
  }
}

class _BookingHero extends StatelessWidget {
  const _BookingHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event_available,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                "Bookings",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Choose a service that fits your wellness goals.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: const [
              _HeroPill(icon: Icons.spa_outlined, text: "Mindfulness"),
              _HeroPill(icon: Icons.restaurant_menu, text: "Nutrition"),
              _HeroPill(icon: Icons.self_improvement, text: "Coaching"),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String text;

  const _CategoryPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  final int minutes;

  const _DurationPill({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            "$minutes min",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
