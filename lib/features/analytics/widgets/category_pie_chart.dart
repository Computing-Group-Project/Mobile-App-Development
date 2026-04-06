import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  static const List<Color> sliceColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    // Updated data will automatically update since we use .watch
    final data = provider.spendingByCategory;

    if (data.isEmpty) return const Center(child: Text('No data yet'));

    final entries = data.entries.toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: List.generate(entries.length, (i) {
                    final entry = entries[i];
                    return PieChartSectionData(
                      color: sliceColors[i % sliceColors.length],
                      value: entry.value,
                      title: entry.key,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: List.generate(entries.length, (i) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: sliceColors[i % sliceColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(entries[i].key, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
