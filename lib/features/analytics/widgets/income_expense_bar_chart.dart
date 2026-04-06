import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  const IncomeExpenseBarChart({super.key});

  static const Color _incomeColor = Color(0xFF01C38D);
  static const Color _expenseColor = Color(0xFFE05C6A);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final theme = Theme.of(context);
    final monthlyData = provider.monthlyTotals;

    if (monthlyData.isEmpty) return const Center(child: Text('No data yet'));

    final months = monthlyData.keys.toList()..sort();

    // Find max value for grid scaling
    double maxVal = 0;
    for (final m in months) {
      final inc = monthlyData[m]!['income'] ?? 0;
      final exp = monthlyData[m]!['expense'] ?? 0;
      if (inc > maxVal) maxVal = inc.toDouble();
      if (exp > maxVal) maxVal = exp.toDouble();
    }

    String _abbrev(double v) {
      if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
      return v.toStringAsFixed(0);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Income vs Expenses', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _legendDot(_incomeColor, 'Income', theme),
                const SizedBox(width: 16),
                _legendDot(_expenseColor, 'Expense', theme),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.25,
                  barGroups: List.generate(months.length, (i) {
                    final month = months[i];
                    final income =
                        (monthlyData[month]!['income'] ?? 0).toDouble();
                    final expense =
                        (monthlyData[month]!['expense'] ?? 0).toDouble();
                    return BarChartGroupData(
                      x: i,
                      groupVertically: false,
                      barRods: [
                        BarChartRodData(
                          toY: income,
                          color: _incomeColor,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          toY: expense,
                          color: _expenseColor,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final month = months[value.toInt()];
                          final parts = month.split('-');
                          const names = [
                            '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              names[int.parse(parts[1])],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == meta.max) {
                            return const SizedBox();
                          }
                          return Text(
                            _abbrev(value),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxVal / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outline.withValues(alpha: 0.25),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = rodIndex == 0 ? 'Income' : 'Expense';
                        return BarTooltipItem(
                          '$label\nLKR ${_abbrev(rod.toY)}',
                          theme.textTheme.labelSmall!.copyWith(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
