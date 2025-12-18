import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/healing_card.dart';
import 'healing_card_seeds.dart';

const _defaultApiBase = 'https://www.synhh.com.au';

class HealingCardService {
  HealingCardService({
    http.Client? client,
    Uri? apiBase,
  })  : _client = client ?? http.Client(),
        _apiBase = apiBase ?? Uri.parse(_defaultApiBase);

  final http.Client _client;
  final Uri _apiBase;

  Future<HealingCard> fetchCardById(String cardId) async {
    final uri = _buildCardUri(cardId);

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw HealingCardRequestException(
        'Failed to load card (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw HealingCardRequestException('Unexpected response shape.');
    }

    final card = HealingCard.fromJson(body);
    if (card.id.isNotEmpty) {
      return card;
    }

    return card.copyWith(id: cardId);
  }

  HealingCard? seedForId(String? id) => findSeedById(id);

  HealingCard? seedForQrValue(String? qrValue) => findSeedByQrValue(qrValue);

  Uri _buildCardUri(String cardId) {
    final trimmed = cardId.trim().toLowerCase();
    final segments = [
      ..._apiBase.pathSegments.where((s) => s.isNotEmpty),
      'healing-cards',
      trimmed,
    ];

    return _apiBase.replace(pathSegments: segments);
  }
}

class HealingCardRequestException implements Exception {
  HealingCardRequestException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'HealingCardRequestException($statusCode): $message';
}

class HealingCardScanParseResult {
  HealingCardScanParseResult({
    required this.rawValue,
    required this.uri,
    required this.cardId,
  });

  final String rawValue;
  final Uri? uri;
  final String? cardId;

  String? get webUrl {
    if (uri != null && (uri!.scheme == 'http' || uri!.scheme == 'https')) {
      return uri.toString();
    }
    return findSeedById(cardId)?.webUrl ??
        findSeedByQrValue(rawValue)?.webUrl;
  }
}

HealingCardScanParseResult parseHealingCardFromScan(String rawValue) {
  final trimmed = rawValue.trim();
  final uri = Uri.tryParse(trimmed);

  String? cardId;
  if (uri != null) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      cardId = segments.last.toLowerCase();
    } else if (uri.path.isNotEmpty) {
      cardId = uri.path.toLowerCase();
    }
  }

  return HealingCardScanParseResult(
    rawValue: trimmed,
    uri: uri,
    cardId: cardId,
  );
}
