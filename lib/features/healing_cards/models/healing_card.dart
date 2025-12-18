class HealingCard {
  const HealingCard({
    required this.id,
    required this.cardNumber,
    required this.title,
    required this.quote,
    required this.appText,
    required this.webUrl,
    required this.qrValue,
  });

  final String id;
  final int cardNumber;
  final String title;
  final String quote;
  final String appText;
  final String webUrl;
  final String qrValue;

  factory HealingCard.fromJson(Map<String, dynamic> json) {
    return HealingCard(
      id: _readString(json['id']),
      cardNumber: _readInt(json['cardNumber']),
      title: _readString(json['title']),
      quote: _readString(json['quote']),
      appText: _readString(json['appText']),
      webUrl: _readString(json['webUrl']),
      qrValue: _readString(json['qrValue']),
    );
  }

  HealingCard copyWith({
    String? id,
    int? cardNumber,
    String? title,
    String? quote,
    String? appText,
    String? webUrl,
    String? qrValue,
  }) {
    return HealingCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      title: title ?? this.title,
      quote: quote ?? this.quote,
      appText: appText ?? this.appText,
      webUrl: webUrl ?? this.webUrl,
      qrValue: qrValue ?? this.qrValue,
    );
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
