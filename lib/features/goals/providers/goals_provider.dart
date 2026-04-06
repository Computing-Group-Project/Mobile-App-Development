import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/financial_event.dart';
import '../models/goal_contribution.dart';
import '../models/savings_goal.dart';
import '../models/wishlist_item.dart';

class GoalsProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<SavingsGoal> _goals = [];
  List<GoalContribution> _contributions = [];
  List<WishlistItem> _wishlist = [];
  List<FinancialEvent> _financialEvents = [];
  double _monthlyWishlistBudget = 0;
  bool _isLoading = false;

  String? get _uid => _auth.currentUser?.uid;

  bool get isLoading => _isLoading;
  List<SavingsGoal> get goals => List.unmodifiable(_goals);
  List<GoalContribution> get contributions => List.unmodifiable(_contributions);
  List<WishlistItem> get wishlist => List.unmodifiable(_wishlist);
  double get monthlyWishlistBudget => _monthlyWishlistBudget;

  double get totalGoalTarget =>
      _goals.fold(0.0, (acc, item) => acc + item.targetAmount);
  double get totalGoalSaved =>
      _goals.fold(0.0, (acc, item) => acc + item.currentAmount);

  Future<void> loadAll() async {
    final uid = _uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadGoals(uid),
        _loadContributions(uid),
        _loadWishlist(uid),
        _loadFinancialEvents(uid),
        _loadWishlistBudget(uid),
      ]);
    } catch (e) {
      debugPrint('GoalsProvider.loadAll error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadGoals(String uid) async {
    final snap = await _db
        .collection('goals')
        .where('userId', isEqualTo: uid)
        .orderBy('targetDate')
        .get();
    _goals = snap.docs.map(SavingsGoal.fromDoc).toList();
  }

  Future<void> _loadContributions(String uid) async {
    final snap = await _db
        .collection('goalContributions')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();
    _contributions = snap.docs.map(GoalContribution.fromDoc).toList();
  }

  Future<void> _loadWishlist(String uid) async {
    final snap = await _db
        .collection('wishlist')
        .where('userId', isEqualTo: uid)
        .get();
    _wishlist = snap.docs.map(WishlistItem.fromDoc).toList();
  }

  Future<void> _loadFinancialEvents(String uid) async {
    final snap = await _db
        .collection('financialEvents')
        .where('userId', isEqualTo: uid)
        .orderBy('date')
        .get();
    _financialEvents = snap.docs.map(FinancialEvent.fromDoc).toList();
  }

  Future<void> _loadWishlistBudget(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      _monthlyWishlistBudget =
          ((doc.data()?['monthlyWishlistBudget'] ?? 0) as num).toDouble();
    }
  }

  List<GoalContribution> contributionsForGoal(String goalId) {
    return _contributions
        .where((item) => item.goalId == goalId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> logGoalContribution({
    required String goalId,
    required double amount,
    DateTime? date,
    String? note,
  }) async {
    final uid = _uid;
    if (uid == null || amount <= 0) return;

    final goalIndex = _goals.indexWhere((item) => item.id == goalId);
    if (goalIndex < 0) return;

    final batch = _db.batch();

    // Add contribution document
    final contribRef = _db.collection('goalContributions').doc();
    batch.set(contribRef, {
      'userId': uid,
      'goalId': goalId,
      'amount': amount,
      'date': Timestamp.fromDate(date ?? DateTime.now()),
      'note': note,
    });

    // Update goal's currentAmount
    final goalRef = _db.collection('goals').doc(goalId);
    batch.update(goalRef, {
      'currentAmount': FieldValue.increment(amount),
    });

    await batch.commit();

    // Update local state
    _goals[goalIndex] = _goals[goalIndex].copyWith(
      currentAmount: _goals[goalIndex].currentAmount + amount,
    );
    _contributions.insert(
      0,
      GoalContribution(
        id: contribRef.id,
        goalId: goalId,
        amount: amount,
        date: date ?? DateTime.now(),
        note: note,
      ),
    );
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = await _db.collection('goals').add(goal.toMap(uid));
    _goals.add(goal.copyWith(id: ref.id));
    notifyListeners();
  }

  Future<void> removeGoal(String id) async {
    await _db.collection('goals').doc(id).delete();
    _goals.removeWhere((g) => g.id == id);
    _contributions.removeWhere((c) => c.goalId == id);
    notifyListeners();
  }

  Future<void> updateMonthlyWishlistBudget(double value) async {
    final uid = _uid;
    if (uid == null || value <= 0) return;
    await _db.collection('users').doc(uid).set(
      {'monthlyWishlistBudget': value},
      SetOptions(merge: true),
    );
    _monthlyWishlistBudget = value;
    notifyListeners();
  }

  Future<void> logWishlistSaving({
    required String itemId,
    required double amount,
  }) async {
    final uid = _uid;
    if (uid == null || amount <= 0) return;

    final index = _wishlist.indexWhere((item) => item.id == itemId);
    if (index < 0) return;

    final newAmount = _wishlist[index].savedAmount + amount;
    await _db.collection('wishlist').doc(itemId).update({
      'savedAmount': newAmount,
    });
    _wishlist[index] = _wishlist[index].copyWith(savedAmount: newAmount);
    notifyListeners();
  }

  Future<void> addWishlistItem(WishlistItem item) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = await _db.collection('wishlist').add(item.toMap(uid));
    _wishlist.add(item.copyWith(id: ref.id));
    notifyListeners();
  }

  Future<void> removeWishlistItem(String id) async {
    await _db.collection('wishlist').doc(id).delete();
    _wishlist.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  Future<void> addFinancialEvent(FinancialEvent event) async {
    final uid = _uid;
    if (uid == null) return;
    final ref =
        await _db.collection('financialEvents').add(event.toMap(uid));
    _financialEvents.add(FinancialEvent(
      id: ref.id,
      title: event.title,
      date: event.date,
      amount: event.amount,
      type: event.type,
      note: event.note,
    ));
    notifyListeners();
  }

  Future<void> removeFinancialEvent(String id) async {
    await _db.collection('financialEvents').doc(id).delete();
    _financialEvents.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  int monthsToAfford(WishlistItem item) {
    final remaining = item.remainingAmount;
    if (remaining <= 0) return 0;
    if (_monthlyWishlistBudget <= 0) return -1;
    return math.max(1, (remaining / _monthlyWishlistBudget).ceil());
  }

  List<FinancialEvent> eventsForDate(DateTime date) {
    return _allEvents.where((e) => _isSameDay(e.date, date)).toList()
      ..sort((a, b) => a.type.index.compareTo(b.type.index));
  }

  List<FinancialEvent> eventsForMonth(DateTime month) {
    return _allEvents
        .where((e) =>
            e.date.year == month.year && e.date.month == month.month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<FinancialEvent> upcomingEvents({int days = 30}) {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    final today = DateTime(now.year, now.month, now.day);
    return _allEvents
        .where((e) =>
            !e.date.isBefore(today) &&
            e.date.isBefore(DateTime(end.year, end.month, end.day + 1)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<FinancialEvent> get _goalMilestones {
    return _goals.map((goal) => FinancialEvent(
          id: 'milestone-${goal.id}',
          title: '${goal.title} target date',
          amount: goal.targetAmount,
          type: FinancialEventType.goalMilestone,
          date: goal.targetDate,
          note: 'Goal milestone',
        )).toList();
  }

  List<FinancialEvent> get _allEvents =>
      [..._financialEvents, ..._goalMilestones];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
