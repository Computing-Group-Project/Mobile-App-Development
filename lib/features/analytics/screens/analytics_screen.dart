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
    final provider = context.read<AnalyticsProvider>(); //read (just get data)
    Future.microtask(() => provider.loadTransactions());
    // Load data when screen opens
  }

  @override
  Widget build(BuildContext context) {
    //creates the whole UI
    final provider = context.watch<AnalyticsProvider>();
    //here screen will update automatically when there is an update

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

                  const SpendingInsights(), //This is not a chart. This is that text based Insights.
                  const SizedBox(height: 16),

                  const CategoryPieChart(),
                  const SizedBox(height: 16),

                  const IncomeExpenseBarChart(),
                  const SizedBox(height: 16),

                  const SpendingTrendLine(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    //resuable method that shows income and expences
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
