import '../models/transaction_model.dart';

class AnalyticsService {
  // ─── Fake Data (replace with Firestore fetch later) ───────────────────────
  List<Transaction> getFakeTransactions() {
    return [
      Transaction(
        id: '1',
        category: 'Food',
        amount: 5000,
        date: DateTime(2024, 3, 1),
        type: 'expense',
        description: 'Groceries',
      ),
      Transaction(
        id: '2',
        category: 'Transport',
        amount: 2000,
        date: DateTime(2024, 3, 3),
        type: 'expense',
        description: 'Bus pass',
      ),
      Transaction(
        id: '3',
        category: 'Shopping',
        amount: 8000,
        date: DateTime(2024, 3, 5),
        type: 'expense',
        description: 'Clothes',
      ),
      Transaction(
        id: '4',
        category: 'Food',
        amount: 3000,
        date: DateTime(2024, 3, 10),
        type: 'expense',
        description: 'Restaurant',
      ),
      Transaction(
        id: '5',
        category: 'Salary',
        amount: 50000,
        date: DateTime(2024, 3, 1),
        type: 'income',
        description: 'Monthly salary',
      ),
      Transaction(
        id: '6',
        category: 'Entertainment',
        amount: 1500,
        date: DateTime(2024, 3, 12),
        type: 'expense',
        description: 'Netflix',
      ),
      Transaction(
        id: '7',
        category: 'Food',
        amount: 2500,
        date: DateTime(2024, 3, 15),
        type: 'expense',
        description: 'Groceries',
      ),
      Transaction(
        id: '8',
        category: 'Freelance',
        amount: 15000,
        date: DateTime(2024, 3, 20),
        type: 'income',
        description: 'Project payment',
      ),
      Transaction(
        id: '9',
        category: 'Transport',
        amount: 1000,
        date: DateTime(2024, 3, 22),
        type: 'expense',
        description: 'Fuel',
      ),
      Transaction(
        id: '10',
        category: 'Shopping',
        amount: 4000,
        date: DateTime(2024, 3, 25),
        type: 'expense',
        description: 'Electronics',
      ),
    ];
  }

  // ─── Total Income ──────────────────────────────────────────────────────────
  double getTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // ─── Total Expense ─────────────────────────────────────────────────────────
  double getTotalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // ─── Spending by Category (for Pie Chart) ─────────────────────────────────
  Map<String, double> getSpendingByCategory(List<Transaction> transactions) {
    Map<String, double> categoryMap = {};
    for (var t in transactions.where((t) => t.type == 'expense')) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    return categoryMap;
  }

  // ─── Monthly Totals (for Bar Chart) ───────────────────────────────────────
  Map<String, Map<String, double>> getMonthlyTotals(
    List<Transaction> transactions,
  ) {
    Map<String, Map<String, double>> monthlyMap = {};
    for (var t in transactions) {
      String monthKey =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      monthlyMap[monthKey] ??= {'income': 0, 'expense': 0};
      monthlyMap[monthKey]![t.type] =
          (monthlyMap[monthKey]![t.type] ?? 0) + t.amount;
    }
    return monthlyMap;
  }

  // ─── Daily Spending (for Trend Line) ──────────────────────────────────────
  Map<DateTime, double> getDailySpending(List<Transaction> transactions) {
    Map<DateTime, double> dailyMap = {};
    for (var t in transactions.where((t) => t.type == 'expense')) {
      DateTime day = DateTime(t.date.year, t.date.month, t.date.day);
      dailyMap[day] = (dailyMap[day] ?? 0) + t.amount;
    }
    return dailyMap;
  }

  // ─── Auto Insights ─────────────────────────────────────────────────────────
  List<String> getInsights(List<Transaction> transactions) {
    List<String> insights = [];
    Map<String, double> byCategory = getSpendingByCategory(transactions);
    double totalExpense = getTotalExpense(transactions);
    double totalIncome = getTotalIncome(transactions);

    // Insight 1: Highest spending category
    if (byCategory.isNotEmpty) {
      String topCategory = byCategory.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      insights.add('You spent the most on $topCategory this month.');
    }

    // Insight 2: Overspending check
    if (totalExpense > totalIncome) {
      insights.add('⚠️ Your expenses exceeded your income this month!');
    } else {
      double saved = totalIncome - totalExpense;
      insights.add(
        '✅ You saved Rs. ${saved.toStringAsFixed(0)} this month. Great job!',
      );
    }

    // Insight 3: Food spending percentage
    if (byCategory.containsKey('Food') && totalExpense > 0) {
      double foodPercent = (byCategory['Food']! / totalExpense) * 100;
      if (foodPercent > 30) {
        insights.add(
          '🍔 Food takes up ${foodPercent.toStringAsFixed(0)}% of your spending.',
        );
      }
    }

    return insights;
  }
}
