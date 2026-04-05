import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/income_expense_bar_chart.dart';
import '../widgets/spending_trend_line.dart';
import '../widgets/spending_insights.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    Future.microtask(
      () => context.read<AnalyticsProvider>().loadTransactions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context
        .watch<AnalyticsProvider>(); //get data from the Provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary Cards ──────────────────────────────
                  Row(
                    children: [
                      _summaryCard(
                        'Income',
                        provider.totalIncome,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _summaryCard(
                        'Expenses',
                        provider.totalExpense,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Insights ───────────────────────────────────
                  const SpendingInsights(),
                  const SizedBox(height: 16),

                  // ── Pie Chart ──────────────────────────────────
                  const CategoryPieChart(),
                  const SizedBox(height: 16),

                  // ── Bar Chart ──────────────────────────────────
                  const IncomeExpenseBarChart(),
                  const SizedBox(height: 16),

                  // ── Line Graph ─────────────────────────────────
                  const SpendingTrendLine(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs. ${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
