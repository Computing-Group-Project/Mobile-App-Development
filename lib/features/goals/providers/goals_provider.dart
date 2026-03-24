import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/financial_event.dart';
import '../models/goal_contribution.dart';
import '../models/savings_goal.dart';
import '../models/wishlist_item.dart';

class GoalsProvider extends ChangeNotifier {
  final List<SavingsGoal> _goals = [
    SavingsGoal(
      id: 'goal-laptop',
      title: 'New Laptop',
      targetAmount: 320000,
      currentAmount: 124000,
      targetDate: DateTime.now().add(const Duration(days: 160)),
      iconKey: 'laptop',
    ),
    SavingsGoal(
      id: 'goal-emergency',
      title: 'Emergency Fund',
      targetAmount: 150000,
      currentAmount: 54000,
      targetDate: DateTime.now().add(const Duration(days: 220)),
      iconKey: 'shield',
    ),
    SavingsGoal(
      id: 'goal-trip',
      title: 'Semester Break Trip',
      targetAmount: 90000,
      currentAmount: 34000,
      targetDate: DateTime.now().add(const Duration(days: 95)),
      iconKey: 'flight',
    ),
  ];

  final List<GoalContribution> _contributions = [
    GoalContribution(
      id: 'contrib-1',
      goalId: 'goal-laptop',
      amount: 15000,
      date: DateTime.now().subtract(const Duration(days: 8)),
      note: 'Freelance UI task',
    ),
    GoalContribution(
      id: 'contrib-2',
      goalId: 'goal-emergency',
      amount: 6000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: 'Monthly top-up',
    ),
    GoalContribution(
      id: 'contrib-3',
      goalId: 'goal-trip',
      amount: 8000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      note: 'Reduced food delivery spending',
    ),
  ];

  final List<WishlistItem> _wishlist = [
    WishlistItem(
      id: 'wish-watch',
      name: 'Smart Watch',
      targetPrice: 42000,
      savedAmount: 9000,
      priority: WishlistPriority.medium,
      desiredBy: DateTime.now().add(const Duration(days: 110)),
    ),
    WishlistItem(
      id: 'wish-headphones',
      name: 'Noise Cancelling Headphones',
      targetPrice: 68000,
      savedAmount: 22000,
      priority: WishlistPriority.high,
      desiredBy: DateTime.now().add(const Duration(days: 130)),
    ),
    WishlistItem(
      id: 'wish-bike',
      name: 'Used Bicycle',
      targetPrice: 55000,
      savedAmount: 12000,
      priority: WishlistPriority.low,
      desiredBy: DateTime.now().add(const Duration(days: 190)),
    ),
  ];

  final List<FinancialEvent> _billEvents = [
    FinancialEvent(
      id: 'bill-hostel',
      title: 'Hostel Fee',
      amount: 25000,
      type: FinancialEventType.bill,
      date: DateTime(DateTime.now().year, DateTime.now().month, 28),
    ),
    FinancialEvent(
      id: 'bill-mobile',
      title: 'Mobile Plan',
      amount: 3490,
      type: FinancialEventType.bill,
      date: DateTime(DateTime.now().year, DateTime.now().month + 1, 6),
    ),
    FinancialEvent(
      id: 'bill-subscriptions',
      title: 'App Subscriptions',
      amount: 1990,
      type: FinancialEventType.bill,
      date: DateTime(DateTime.now().year, DateTime.now().month + 1, 12),
    ),
  ];

  final List<FinancialEvent> _incomeEvents = [
    FinancialEvent(
      id: 'income-part-time',
      title: 'Part-time Salary',
      amount: 38000,
      type: FinancialEventType.income,
      date: DateTime(DateTime.now().year, DateTime.now().month, 30),
    ),
    FinancialEvent(
      id: 'income-scholarship',
      title: 'Scholarship Payment',
      amount: 20000,
      type: FinancialEventType.income,
      date: DateTime(DateTime.now().year, DateTime.now().month + 1, 15),
    ),
  ];

  double _monthlyWishlistBudget = 12000;

  List<SavingsGoal> get goals => List.unmodifiable(_goals);

  List<GoalContribution> get contributions => List.unmodifiable(_contributions);

  List<WishlistItem> get wishlist => List.unmodifiable(_wishlist);

  double get monthlyWishlistBudget => _monthlyWishlistBudget;

  double get totalGoalTarget =>
      _goals.fold(0, (sum, item) => sum + item.targetAmount);

  double get totalGoalSaved =>
      _goals.fold(0, (sum, item) => sum + item.currentAmount);

  List<GoalContribution> contributionsForGoal(String goalId) {
    final filtered =
        _contributions.where((item) => item.goalId == goalId).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void logGoalContribution({
    required String goalId,
    required double amount,
    DateTime? date,
    String? note,
  }) {
    if (amount <= 0) {
      return;
    }

    final goalIndex = _goals.indexWhere((item) => item.id == goalId);
    if (goalIndex < 0) {
      return;
    }

    final selectedGoal = _goals[goalIndex];
    _goals[goalIndex] = selectedGoal.copyWith(
      currentAmount: selectedGoal.currentAmount + amount,
    );

    _contributions.add(
      GoalContribution(
        id: 'contrib-${DateTime.now().microsecondsSinceEpoch}',
        goalId: goalId,
        amount: amount,
        date: date ?? DateTime.now(),
        note: note,
      ),
    );

    notifyListeners();
  }

  void updateMonthlyWishlistBudget(double value) {
    if (value <= 0) {
      return;
    }
    _monthlyWishlistBudget = value;
    notifyListeners();
  }

  void logWishlistSaving({required String itemId, required double amount}) {
    if (amount <= 0) {
      return;
    }

    final index = _wishlist.indexWhere((item) => item.id == itemId);
    if (index < 0) {
      return;
    }

    _wishlist[index] = _wishlist[index].copyWith(
      savedAmount: _wishlist[index].savedAmount + amount,
    );

    notifyListeners();
  }

  int monthsToAfford(WishlistItem item) {
    final remaining = item.remainingAmount;
    if (remaining <= 0) {
      return 0;
    }

    if (_monthlyWishlistBudget <= 0) {
      return -1;
    }

    return math.max(1, (remaining / _monthlyWishlistBudget).ceil());
  }

  List<FinancialEvent> eventsForDate(DateTime date) {
    final allEvents = _allEvents;
    return allEvents.where((event) => _isSameDay(event.date, date)).toList()
      ..sort((a, b) => a.type.index.compareTo(b.type.index));
  }

  List<FinancialEvent> eventsForMonth(DateTime month) {
    return _allEvents
        .where(
          (event) =>
              event.date.year == month.year && event.date.month == month.month,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<FinancialEvent> upcomingEvents({int days = 30}) {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));

    return _allEvents
        .where(
          (event) =>
              event.date.isAfter(
                DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(const Duration(days: 1)),
              ) &&
              event.date.isBefore(DateTime(end.year, end.month, end.day + 1)),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<FinancialEvent> get _goalMilestones {
    return _goals
        .map(
          (goal) => FinancialEvent(
            id: 'milestone-${goal.id}',
            title: '${goal.title} target date',
            amount: goal.targetAmount,
            type: FinancialEventType.goalMilestone,
            date: goal.targetDate,
            note: 'Goal milestone',
          ),
        )
        .toList();
  }

  List<FinancialEvent> get _allEvents {
    return [..._billEvents, ..._incomeEvents, ..._goalMilestones];
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
