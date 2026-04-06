import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AnalyticsService {
  double getTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getSpendingByCategory(List<Transaction> transactions) {
    final categoryMap = <String, double>{};
    for (final t in transactions.where((t) => t.type == 'expense')) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    return categoryMap;
  }

  Map<String, Map<String, double>> getMonthlyTotals(
    List<Transaction> transactions,
  ) {
    final monthlyMap = <String, Map<String, double>>{};
    for (final t in transactions) {
      final monthKey =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      monthlyMap[monthKey] ??= {'income': 0, 'expense': 0};
      monthlyMap[monthKey]![t.type] =
          (monthlyMap[monthKey]![t.type] ?? 0) + t.amount;
    }
    return monthlyMap;
  }

  Map<DateTime, double> getDailySpending(List<Transaction> transactions) {
    final dailyMap = <DateTime, double>{};
    for (final t in transactions.where((t) => t.type == 'expense')) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      dailyMap[day] = (dailyMap[day] ?? 0) + t.amount;
    }
    return dailyMap;
  }

  List<String> getInsights(List<Transaction> transactions) {
    final insights = <String>[];
    final byCategory = getSpendingByCategory(transactions);
    final totalExpense = getTotalExpense(transactions);
    final totalIncome = getTotalIncome(transactions);

    if (byCategory.isNotEmpty) {
      final topCategory =
          byCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      insights.add('You spent the most on $topCategory this month.');
    }

    if (totalExpense > totalIncome) {
      insights.add('Your expenses exceeded your income this month.');
    } else if (totalIncome > 0) {
      final saved = totalIncome - totalExpense;
        final fmt = NumberFormat('#,##0', 'en_US');
        insights.add(
          'You saved LKR ${fmt.format(saved)} this month. Great job!',
        );
    }

    if (byCategory.containsKey('Food & Drinks') && totalExpense > 0) {
      final foodPercent = (byCategory['Food & Drinks']! / totalExpense) * 100;
      if (foodPercent > 30) {
        insights.add(
          'Food takes up ${foodPercent.toStringAsFixed(0)}% of your spending.',
        );
      }
    }

    return insights;
  }
}
