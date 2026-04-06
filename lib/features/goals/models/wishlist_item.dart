import 'package:cloud_firestore/cloud_firestore.dart';

enum WishlistPriority { low, medium, high }

class WishlistItem {
  final String id;
  final String name;
  final double targetPrice;
  final double savedAmount;
  final DateTime? desiredBy;
  final WishlistPriority priority;

  const WishlistItem({
    required this.id,
    required this.name,
    required this.targetPrice,
    required this.savedAmount,
    required this.priority,
    this.desiredBy,
  });

  double get remainingAmount =>
      (targetPrice - savedAmount).clamp(0.0, double.infinity);

  double get progress {
    if (targetPrice <= 0) return 0;
    return (savedAmount / targetPrice).clamp(0.0, 1.0);
  }

  factory WishlistItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistItem(
      id: doc.id,
      name: data['name'] ?? '',
      targetPrice: (data['targetPrice'] ?? 0).toDouble(),
      savedAmount: (data['savedAmount'] ?? 0).toDouble(),
      priority: WishlistPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => WishlistPriority.medium,
      ),
      desiredBy: data['desiredBy'] != null
          ? (data['desiredBy'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'name': name,
      'targetPrice': targetPrice,
      'savedAmount': savedAmount,
      'priority': priority.name,
      'desiredBy':
          desiredBy != null ? Timestamp.fromDate(desiredBy!) : null,
    };
  }

  WishlistItem copyWith({
    String? id,
    String? name,
    double? targetPrice,
    double? savedAmount,
    DateTime? desiredBy,
    WishlistPriority? priority,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      targetPrice: targetPrice ?? this.targetPrice,
      savedAmount: savedAmount ?? this.savedAmount,
      desiredBy: desiredBy ?? this.desiredBy,
      priority: priority ?? this.priority,
    );
  }
}
