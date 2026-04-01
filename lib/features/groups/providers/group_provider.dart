import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _service = GroupService();

  String get uid {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw Exception("No user");
    return u.uid;
  }

  Stream<List<GroupModel>> get groupsStream =>
      _service.streamUserGroups(uid);

  Stream<List<SharedExpense>> expensesStream(String groupId) =>
      _service.streamGroupExpenses(groupId);

  Stream<List<Settlement>> settlementsStream(String groupId) =>
      _service.streamSettlements(groupId);

  Future<void> createGroup(String name, List<GroupMember> members) async {
    await _service.createGroup(
      name: name,
      createdBy: uid,
      members: members,
    );
  }

  Future<void> addExpense(SharedExpense e) async {
    await _service.addExpense(e);
  }

  Future<void> recordSettlement(Settlement settlement) async {
    await _service.recordSettlement(settlement);
  }
}
