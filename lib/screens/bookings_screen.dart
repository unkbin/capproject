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
          // Title
          Text(
            "Bookings",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text("Choose a service that fits your wellness goals.",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 20),

          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((c) {
                final selected = c == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => selectedCategory = c);
                    },
                    selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade800,
                    ),
                  ),
                );
              }).toList(),
            ),
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
                final booking = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(service: service),
                  ),
                );

                if (booking != null) {
                  onBookingConfirmed(booking);
                  ScaffoldMessenger.of(context).showSnackBar(
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

/// ─────────────────────────────────────────
/// Data models
/// ─────────────────────────────────────────

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

/// ─────────────────────────────────────────
/// UI Components
/// ─────────────────────────────────────────

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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: Image.network(
                service.image,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${service.duration} min • ${service.category}",
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
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
