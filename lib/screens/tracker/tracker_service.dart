import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerEntry {
  TrackerEntry({
    required this.dateId,
    required this.mood,
    required this.hydration,
    required this.movement,
    required this.sleep,
    required this.updatedAt,
  });

  final String dateId; // yyyy-MM-dd
  final String mood;
  final double hydration; // 0..100
  final double movement; // minutes
  final double sleep; // hours
  final DateTime? updatedAt;

  factory TrackerEntry.fromDoc(String id, Map<String, dynamic> data) {
    return TrackerEntry(
      dateId: id,
      mood: (data['mood'] as String?) ?? 'Okay',
      hydration: _toDouble(data['hydration'], fallback: 50),
      movement: _toDouble(data['movement'], fallback: 30),
      sleep: _toDouble(data['sleep'], fallback: 7),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'date': dateId,
    'mood': mood,
    'hydration': hydration,
    'movement': movement,
    'sleep': sleep,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static double _toDouble(dynamic v, {required double fallback}) {
    if (v is num) return v.toDouble();
    return fallback;
  }
}

class TrackerService {
  const TrackerService();

  CollectionReference<Map<String, dynamic>> _checkinsRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('checkins');
  }

  static String dateId(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<TrackerEntry?> loadDay(String uid, String dayId) async {
    final snap = await _checkinsRef(uid).doc(dayId).get();
    final data = snap.data();
    if (data == null) return null;
    return TrackerEntry.fromDoc(snap.id, data);
  }

  Future<void> saveDay(String uid, TrackerEntry entry) async {
    await _checkinsRef(uid)
        .doc(entry.dateId)
        .set(entry.toMap(), SetOptions(merge: true));
  }

  /// Last N days (including today), newest first.
  Future<List<TrackerEntry>> loadRecentDays(String uid, {int limit = 7}) async {
    final snap = await _checkinsRef(uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((d) => TrackerEntry.fromDoc(d.id, d.data()))
        .toList();
  }

  /// Consecutive days streak ending today (or yesterday if no entry today).
  Future<int> computeStreak(String uid) async {
    // Fetch recent docs so we can compute streak locally.
    // If you want longer streaks, increase this limit.
    final recent = await loadRecentDays(uid, limit: 60);
    if (recent.isEmpty) return 0;

    final set = recent.map((e) => e.dateId).toSet();

    final today = DateTime.now();
    final todayId = dateId(today);
    final yesterdayId = dateId(today.subtract(const Duration(days: 1)));

    // Streak anchor:
    // - If user checked in today, start at today
    // - else if checked in yesterday, start at yesterday
    // - else streak is 0
    DateTime cursor;
    if (set.contains(todayId)) {
      cursor = today;
    } else if (set.contains(yesterdayId)) {
      cursor = today.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    var streak = 0;
    while (true) {
      final id = dateId(cursor);
      if (!set.contains(id)) break;
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
