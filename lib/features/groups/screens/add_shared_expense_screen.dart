import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../providers/group_provider.dart';
import '../widgets/split_selector.dart';

class AddSharedExpenseScreen extends StatefulWidget {
  final GroupModel group;

  const AddSharedExpenseScreen({super.key, required this.group});

  @override
  State<AddSharedExpenseScreen> createState() =>
      _AddSharedExpenseScreenState();
}

class _AddSharedExpenseScreenState extends State<AddSharedExpenseScreen> {
  final _title = TextEditingController();
  final _amount = TextEditingController();

  SplitType _type = SplitType.equal;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();

    for (var m in widget.group.members) {
      _controllers[m.uid] = TextEditingController(text: "0");
    }

    _amount.addListener(_recalculateEqual);
  }

  double get _total =>
      double.tryParse(_amount.text.trim()) ?? 0;

  double get _sum => _controllers.values.fold(
        0,
        (a, c) => a + (double.tryParse(c.text) ?? 0),
      );

  // ✅ AUTO CALCULATE EQUAL SPLIT
  void _recalculateEqual() {
    if (_type != SplitType.equal) return;
    if (_total <= 0) return;

    final share = _total / widget.group.members.length;

    for (var c in _controllers.values) {
      c.text = share.toStringAsFixed(2);
    }

    setState(() {});
  }

  // ✅ VALIDATION
  bool _isValid() {
    if (_type == SplitType.equal) return true;

    if (_type == SplitType.custom) {
      return (_sum - _total).abs() < 0.01;
    }

    if (_type == SplitType.percentage) {
      return (_sum - 100).abs() < 0.01;
    }

    return false;
  }

  // ✅ BUILD SPLITS
  List<MemberSplit> _buildSplits() {
    return widget.group.members.map((m) {
      final val = double.tryParse(_controllers[m.uid]!.text) ?? 0;

      if (_type == SplitType.equal) {
        return MemberSplit(
          uid: m.uid,
          name: m.name,
          amount: _total / widget.group.members.length,
        );
      }

      if (_type == SplitType.custom) {
        return MemberSplit(
          uid: m.uid,
          name: m.name,
          amount: val,
        );
      }

      return MemberSplit(
        uid: m.uid,
        name: m.name,
        amount: _total * val / 100,
        percentage: val,
      );
    }).toList();
  }

  // ✅ SAVE FUNCTION (SAFE)
  Future<void> _save() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      if (_title.text.trim().isEmpty || _total <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter valid data")),
        );
        return;
      }

      if (!_isValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid split values")),
        );
        return;
      }

      final expense = SharedExpense(
        id: '',
        groupId: widget.group.id,
        title: _title.text.trim(),
        totalAmount: _total,
        paidBy: user.uid,
        paidByName: user.displayName ?? user.email ?? 'Unknown',
        splitType: _type,
        splits: _buildSplits(),
        createdAt: DateTime.now(),
      );

      await context.read<GroupProvider>().addExpense(expense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ✅ MEMBER ROW
  Widget _memberRow(BuildContext context, GroupMember m) {
    final theme = Theme.of(context);
    final isEqual = _type == SplitType.equal;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Text(
                m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(m.name, style: theme.textTheme.bodyMedium),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controllers[m.uid],
                enabled: !isEqual,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isEqual
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: _type == SplitType.percentage ? '%' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _type == SplitType.custom ? _total - _sum : 100 - _sum;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        children: [
          // ── Details section ──────────────────────────────────────────────
          Text('Details', style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          )),
          const SizedBox(height: 10),

          TextField(
            controller: _title,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefix: Text('LKR ', style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              )),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 24),

          // ── Split type section ───────────────────────────────────────────
          Text('Split Type', style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          )),
          const SizedBox(height: 10),

          SplitSelector(
            selected: _type,
            onChanged: (type) {
              setState(() {
                _type = type;
                if (type == SplitType.equal) {
                  _recalculateEqual();
                } else {
                  for (var c in _controllers.values) {
                    c.clear();
                  }
                }
              });
            },
          ),

          if (_type != SplitType.equal) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  remaining.abs() < 0.01
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 14,
                  color: remaining.abs() < 0.01
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  _type == SplitType.custom
                      ? 'Remaining: LKR ${remaining.toStringAsFixed(2)}'
                      : 'Total: ${_sum.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: remaining.abs() < 0.01
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // ── Members section ──────────────────────────────────────────────
          Text('Members', style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          )),
          const SizedBox(height: 10),

          ...widget.group.members.map((m) => _memberRow(context, m)),

          const SizedBox(height: 32),

          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Save Expense', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}