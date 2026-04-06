import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';

class SpendingTrendLine extends StatelessWidget {
  const SpendingTrendLine({super.key});

  static const Color _lineColor = Color(0xFF01C38D);

  /// 3-day rolling average to smooth out single-day spikes
  List<FlSpot> _smoothed(List<DateTime> days, Map<DateTime, double> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final from = (i - 1).clamp(0, days.length - 1);
      final to = (i + 1).clamp(0, days.length - 1);
      double sum = 0;
      int count = 0;
      for (int j = from; j <= to; j++) {
        sum += data[days[j]] ?? 0;
        count++;
      }
      spots.add(FlSpot(i.toDouble(), sum / count));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final theme = Theme.of(context);
    final dailyData = provider.dailySpending;

    if (dailyData.isEmpty) return const Center(child: Text('No data yet'));

    final sortedDays = dailyData.keys.toList()..sort();
    final spots = _smoothed(sortedDays, dailyData);

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    // Show ~5 evenly spaced date labels as "MMM d"
    final labelInterval = (sortedDays.length / 5).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Trend', style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: _lineColor,
                      barWidth: 2.5,
                      // Gradient fill under the line
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _lineColor.withValues(alpha: 0.45),
                            _lineColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      // Highlight only the last data point
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) =>
                            spot.x == spots.last.x,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: _lineColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: labelInterval,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedDays.length) {
                            return const SizedBox();
                          }
                          // Skip if too close to the last index to avoid overlap
                          if (index != spots.last.x.toInt() &&
                              (spots.last.x - index) < labelInterval * 0.6) {
                            return const SizedBox();
                          }
                          final d = sortedDays[index];
                          const months = [
                            '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${months[d.month]} ${d.day}',
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
                        reservedSize: 46,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == meta.max) {
                            return const SizedBox();
                          }
                          String label;
                          if (value >= 1000) {
                            label = '${(value / 1000).toStringAsFixed(0)}K';
                          } else {
                            label = value.toStringAsFixed(0);
                          }
                          return Text(
                            label,
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
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((s) {
                        final d = sortedDays[s.x.toInt()];
                        const months = [
                          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                        ];
                        return LineTooltipItem(
                          '${months[d.month]} ${d.day}\nLKR ${s.y.toStringAsFixed(0)}',
                          theme.textTheme.labelSmall!
                              .copyWith(color: Colors.white),
                        );
                      }).toList(),
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
}
