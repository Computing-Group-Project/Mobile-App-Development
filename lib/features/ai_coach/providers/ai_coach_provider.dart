import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/ai_coach_service.dart';

class AiCoachProvider extends ChangeNotifier {
  final AiCoachService _service = AiCoachService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Rate limit tracking (Gemini 2.5 Flash paid tier: 1000 RPM, no hard daily limit)
  static const int kDailyLimit = 1500;
  static const int kPerMinuteLimit = 30;

  int _dailyCount = 0;
  List<DateTime> _minuteTimestamps = []; // timestamps of requests in last 60s
  String _lastResetDate = '';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  int get dailyCount => _dailyCount;
  int get dailyRemaining => kDailyLimit - _dailyCount;
  int get perMinuteUsed => _minuteTimestamps.length;
  int get perMinuteRemaining => kPerMinuteLimit - _minuteTimestamps.length;
  bool get isDailyLimitReached => _dailyCount >= kDailyLimit;
  bool get isMinuteLimitReached => _minuteTimestamps.length >= kPerMinuteLimit;
  bool get isDailyWarning => dailyRemaining <= 150; // warn at ~10% remaining
  bool get isMinuteWarning => perMinuteRemaining <= 5;

  AiCoachProvider() {
    _loadRateLimitData();
  }

  Future<void> _loadRateLimitData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    _lastResetDate = prefs.getString('ai_rate_date') ?? today;

    if (_lastResetDate != today) {
      // New day — reset daily count
      _dailyCount = 0;
      _lastResetDate = today;
      await prefs.setInt('ai_daily_count', 0);
      await prefs.setString('ai_rate_date', today);
    } else {
      _dailyCount = prefs.getInt('ai_daily_count') ?? 0;
    }

    final stored = prefs.getString('ai_minute_timestamps');
    if (stored != null) {
      final list = (jsonDecode(stored) as List).cast<int>();
      _minuteTimestamps = list
          .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms))
          .toList();
    }
    _pruneMinuteWindow();
    notifyListeners();
  }

  void _pruneMinuteWindow() {
    final cutoff = DateTime.now().subtract(const Duration(seconds: 60));
    _minuteTimestamps.removeWhere((t) => t.isBefore(cutoff));
  }

  Future<void> _recordRequest() async {
    _pruneMinuteWindow();
    final now = DateTime.now();
    _minuteTimestamps.add(now);
    _dailyCount++;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ai_daily_count', _dailyCount);
    await prefs.setString(
      'ai_minute_timestamps',
      jsonEncode(_minuteTimestamps.map((t) => t.millisecondsSinceEpoch).toList()),
    );
    notifyListeners();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> sendMessage(String text) async {
    _pruneMinuteWindow();

    if (isDailyLimitReached) {
      _messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: 'Daily request limit reached (1,500/day). The coach will be available again tomorrow.',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    if (isMinuteLimitReached) {
      _messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: 'Too many requests — please wait a moment before trying again (limit: 30/min).',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    _messages.add(ChatMessage(
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      await _recordRequest();
      final context = await _buildTransactionContext();
      final history = _messages
          .take(_messages.length - 1) // exclude the message just added
          .map((m) => {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final reply = await _service.sendMessage(
        userMessage: text,
        transactionContext: context,
        history: history,
      );

      _messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: reply,
        timestamp: DateTime.now(),
      ));
    } catch (e, stack) {
      debugPrint('AI Coach error: $e');
      debugPrint('$stack');
      final errStr = e.toString();
      String userMessage;
      if (errStr.contains('429') || errStr.contains('RESOURCE_EXHAUSTED')) {
        // Extract retry delay if present
        final retryMatch = RegExp(r'retry in (\d+)').firstMatch(errStr);
        final retrySec = retryMatch?.group(1);
        userMessage = retrySec != null
            ? 'The AI coach is temporarily unavailable due to rate limiting. Please try again in $retrySec seconds.'
            : 'The AI coach is temporarily unavailable due to rate limiting. Please try again shortly.';
      } else {
        userMessage = 'Something went wrong. Please try again.';
      }
      _messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: userMessage,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the user's 30 most recent transactions from Firestore and formats
  /// them as a plain-text list for the LLM system prompt.
  Future<String> _buildTransactionContext() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'No transaction data available.';

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(30)
        .get();

    if (snapshot.docs.isEmpty) return 'No transactions recorded yet.';

    final buffer = StringBuffer();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final type = data['type'] ?? 'expense';
      final amount = (data['amount'] as num?)?.toStringAsFixed(2) ?? '0.00';
      final category = data['category'] ?? 'Uncategorized';
      final note = data['note'] ?? '';
      final date = (data['date'] as Timestamp?)?.toDate();
      final dateStr = date != null
          ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          : 'Unknown date';
      buffer.writeln('- $dateStr | $type | $category | LKR $amount${note.isNotEmpty ? ' | $note' : ''}');
    }
    return buffer.toString();
  }

  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }
}
