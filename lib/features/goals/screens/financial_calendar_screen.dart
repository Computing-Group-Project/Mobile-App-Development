import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/financial_event.dart';
import '../providers/goals_provider.dart';

class FinancialCalendarScreen extends StatefulWidget {
  const FinancialCalendarScreen({super.key});

  @override
  State<FinancialCalendarScreen> createState() =>
      _FinancialCalendarScreenState();
}

class _FinancialCalendarScreenState extends State<FinancialCalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    Future.microtask(() {
      if (mounted) context.read<GoalsProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsByDay = _groupByDay(
      context.watch<GoalsProvider>().eventsForMonth(_visibleMonth),
    );
    final selectedDayEvents = context.watch<GoalsProvider>().eventsForDate(
      _selectedDate,
    );
    final upcoming = context.watch<GoalsProvider>().upcomingEvents(days: 21);

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MonthHeader(
            visibleMonth: _visibleMonth,
            onPrevious: () {
              setState(() {
                _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month - 1,
                );
              });
            },
            onNext: () {
              setState(() {
                _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month + 1,
                );
              });
            },
          ),
          const SizedBox(height: 10),
          _WeekdayHeader(),
          const SizedBox(height: 6),
          _CalendarGrid(
            month: _visibleMonth,
            selectedDate: _selectedDate,
            eventsByDay: eventsByDay,
            onSelectDate: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 14),
          const _Legend(),
          const SizedBox(height: 18),
          Text(
            'Events on ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (selectedDayEvents.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'No bills, income dates, or goal milestones for this day.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...selectedDayEvents.map((event) => _EventTile(event: event)),
          const SizedBox(height: 18),
          Text(
            'Upcoming (next 21 days)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text('No upcoming events'),
              ),
            )
          else
            ...upcoming.map((event) => _EventTile(event: event)),
        ],
      ),
    );
  }

  Map<DateTime, List<FinancialEvent>> _groupByDay(List<FinancialEvent> events) {
    final map = <DateTime, List<FinancialEvent>>{};
    for (final event in events) {
      final key = DateTime(event.date.year, event.date.month, event.date.day);
      map.putIfAbsent(key, () => []);
      map[key]!.add(event);
    }
    return map;
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime visibleMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.visibleMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF01C38D),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(visibleMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: [
        for (final weekday in weekdays)
          Expanded(
            child: Text(
              weekday,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final Map<DateTime, List<FinancialEvent>> eventsByDay;
  final ValueChanged<DateTime> onSelectDate;

  const _CalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.eventsByDay,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final firstWeekday = (firstDay.weekday + 6) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final slots = <DateTime?>[
      for (var i = 0; i < firstWeekday; i++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(month.year, month.month, day),
    ];

    while (slots.length % 7 != 0) {
      slots.add(null);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final date = slots[index];
        if (date == null) {
          return const SizedBox.shrink();
        }

        final dayKey = DateTime(date.year, date.month, date.day);
        final events = eventsByDay[dayKey] ?? [];
        final isSelected =
            dayKey.year == selectedDate.year &&
            dayKey.month == selectedDate.month &&
            dayKey.day == selectedDate.day;

        return InkWell(
          onTap: () => onSelectDate(dayKey),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.day.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: events.take(3).map((event) {
                    return Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _eventColor(event.type),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _eventColor(FinancialEventType type) {
    switch (type) {
      case FinancialEventType.bill:
        return Colors.red;
      case FinancialEventType.income:
        return Colors.green;
      case FinancialEventType.goalMilestone:
        return Colors.blue;
    }
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        _LegendItem(label: 'Bills', color: Colors.red),
        _LegendItem(label: 'Income', color: Colors.green),
        _LegendItem(label: 'Goal milestones', color: Colors.blue),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final FinancialEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'LKR ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _typeColor(event.type).withValues(alpha: 0.15),
          child: Icon(_typeIcon(event.type), color: _typeColor(event.type)),
        ),
        title: Text(event.title),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(event.date)),
        trailing: Text(
          currency.format(event.amount),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Color _typeColor(FinancialEventType type) {
    switch (type) {
      case FinancialEventType.bill:
        return Colors.red;
      case FinancialEventType.income:
        return Colors.green;
      case FinancialEventType.goalMilestone:
        return Colors.blue;
    }
  }

  IconData _typeIcon(FinancialEventType type) {
    switch (type) {
      case FinancialEventType.bill:
        return Icons.receipt_long;
      case FinancialEventType.income:
        return Icons.payments;
      case FinancialEventType.goalMilestone:
        return Icons.flag;
    }
  }
}
