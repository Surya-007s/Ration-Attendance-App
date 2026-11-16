import 'dart:convert';

/// Helper utility for extracting Rice Card / Ration Card numbers
/// from various QR code formats, JSON payloads, URLs, and raw text.
class QRParser {
  /// Extracts a valid card number string from scanned raw content.
  static String? extractCardNumber(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    // 1. Try URL query parameters (Priority 1: AePDS URL)
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      try {
        final uri = Uri.parse(cleaned);
        // Map query parameters to lowercase keys for case-insensitive matching
        final lowercaseParams = uri.queryParameters.map((k, v) => MapEntry(k.toLowerCase(), v));
        
        for (final param in [
          'rcno',
          'cardno',
          'card_number',
          'cardnumber',
          'card',
          'id'
        ]) {
          final val = lowercaseParams[param];
          if (val != null && val.isNotEmpty) {
            return val;
          }
        }
      } catch (_) {}
    }

    // 2. Try JSON decoding
    if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
      try {
        final decoded = jsonDecode(cleaned);
        if (decoded is Map<String, dynamic>) {
          // Map to lowercase keys
          final lowercaseMap = decoded.map((k, v) => MapEntry(k.toLowerCase(), v));
          for (final key in [
            'cardnumber',
            'card_number',
            'cardno',
            'card_no',
            'rationcard',
            'ration_card',
            'rcno'
          ]) {
            if (lowercaseMap.containsKey(key) && lowercaseMap[key] != null) {
              return lowercaseMap[key].toString().trim();
            }
          }
        }
      } catch (_) {}
    }

    // 3. Explicit Key-Value format
    final kvMatch = RegExp(
      r'(card|card_no|cardno|cardnumber|card_number|rationcard|ration_card|rcno)\s*[:=\-]\s*([A-Za-z0-9]+)',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (kvMatch != null) {
      return kvMatch.group(2)!;
    }

    // 4. Match AP / WAP / RAP / YSR prefixed card numbers (e.g. AP1234567890, WAP1234567890)
    // Only return if the ENTIRE string matches (or it's the only thing in it) to avoid arbitrary matching
    // But user said: "Do NOT extract arbitrary numbers from the payload."
    // We will allow exact prefix matches
    final prefixMatch = RegExp(
      r'^(WAP|AP|RAP|YSR)\d{8,20}$',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (prefixMatch != null) {
      return prefixMatch.group(0)!.toUpperCase();
    }
    
    // 5. Exact 10 digit number if the QR is JUST the number
    final exactMatch = RegExp(r'^\d{10,12}$').firstMatch(cleaned);
    if (exactMatch != null) {
        return exactMatch.group(0)!;
    }

    return null;
  }
}
