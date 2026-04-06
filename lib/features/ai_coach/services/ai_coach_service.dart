import 'dart:convert';
import 'package:http/http.dart' as http;

// Store your API key in a gitignored file: lib/core/constants/secrets.dart
// Example content:
//   const String kGeminiApiKey = 'AIzaSy...';
import '../../../core/constants/secrets.dart';

class AiCoachService {
  static const _model = 'gemini-2.5-flash';

  /// Sends [userMessage] to Gemini with [transactionContext] as background.
  /// Returns the assistant's reply text.
  Future<String> sendMessage({
    required String userMessage,
    required String transactionContext,
    required List<Map<String, String>> history,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$_model:generateContent?key=$kGeminiApiKey',
    );

    final systemPrompt = '''
You are FundFlow's AI spending coach — a friendly, practical financial advisor
for university students. You have access to the user's recent transaction history
below. Use it to give personalised, specific advice. Keep responses concise and
actionable. Do not fabricate numbers that are not in the provided data.
Always use LKR (Sri Lankan Rupees) for all monetary amounts. Never use \$ or USD.

=== Recent Transactions ===
$transactionContext
===========================
''';

    // Build conversation history in Gemini format
    final contents = <Map<String, dynamic>>[];

    // Prepend system prompt as the first user turn
    contents.add({
      'role': 'user',
      'parts': [{'text': systemPrompt}],
    });
    contents.add({
      'role': 'model',
      'parts': [{'text': 'Understood. I\'m ready to help as your FundFlow spending coach.'}],
    });

    for (final msg in history) {
      contents.add({
        'role': msg['role'] == 'assistant' ? 'model' : 'user',
        'parts': [{'text': msg['content']}],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [{'text': userMessage}],
    });

    final response = await http.post(
      url,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': {'maxOutputTokens': 2048},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI Coach error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }
}
