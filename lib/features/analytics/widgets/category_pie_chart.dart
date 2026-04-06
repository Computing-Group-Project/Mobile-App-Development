import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  static const List<Color> sliceColors = [
    Color(0xFF01C38D),
    Color(0xFF4FC3F7),
    Color(0xFFFFB74D),
    Color(0xFFE05C6A),
    Color(0xFFBA68C8),
    Color(0xFF4DB6AC),
    Color(0xFFFF8A65),
    Color(0xFF5C7AEA),
    Color(0xFF90A4AE),
    Color(0xFFA5D6A7),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final theme = Theme.of(context);
    final data = provider.spendingByCategory;

    if (data.isEmpty) return const Center(child: Text('No data yet'));

    // Sort by value descending
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: List.generate(entries.length, (i) {
                    return PieChartSectionData(
                      color: sliceColors[i % sliceColors.length],
                      value: entries[i].value,
                      title: '',
                      radius: 70,
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 2-column legend — each column self-contained so % stays with its label
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: even indices
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < (entries.length / 2).ceil(); i++)
                        _LegendItem(
                          color: sliceColors[i % sliceColors.length],
                          label: entries[i].key,
                          percent: entries[i].value / total * 100,
                          theme: theme,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right column: second half
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = (entries.length / 2).ceil(); i < entries.length; i++)
                        _LegendItem(
                          color: sliceColors[i % sliceColors.length],
                          label: entries[i].key,
                          percent: entries[i].value / total * 100,
                          theme: theme,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percent,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
