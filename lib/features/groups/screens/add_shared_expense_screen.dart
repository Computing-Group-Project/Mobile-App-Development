import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../providers/group_provider.dart';

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

  // ✅ SPLIT BUTTON UI
  Widget _splitButton(SplitType type, String label) {
    final selected = _type == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ MEMBER ROW
  Widget _memberRow(GroupMember m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(m.name)),

          SizedBox(
            width: 90,
            child: TextField(
              controller: _controllers[m.uid],
              enabled: _type != SplitType.equal,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
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
    final remaining = _type == SplitType.custom
        ? _total - _sum
        : 100 - _sum;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _splitButton(SplitType.equal, "Equal"),
                const SizedBox(width: 6),
                _splitButton(SplitType.custom, "Custom"),
                const SizedBox(width: 6),
                _splitButton(SplitType.percentage, "Percent"),
              ],
            ),

            const SizedBox(height: 16),

            if (_type != SplitType.equal)
              Text(
                _type == SplitType.custom
                    ? "Remaining: ${remaining.toStringAsFixed(2)}"
                    : "Total: ${_sum.toStringAsFixed(0)}%",
                style: TextStyle(
                  color:
                      remaining.abs() < 0.01 ? Colors.green : Colors.red,
                ),
              ),

            const SizedBox(height: 10),

            ...widget.group.members.map(_memberRow),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}