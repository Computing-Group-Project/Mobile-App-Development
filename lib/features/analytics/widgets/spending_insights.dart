import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';

class SpendingInsights extends StatelessWidget {
  const SpendingInsights({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final insights = provider.insights;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (insights.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: primary, size: 18),
                const SizedBox(width: 8),
                Text('Spending Insights', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 14),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.07),
                    border: Border(
                      left: BorderSide(color: primary, width: 3),
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    insight,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
