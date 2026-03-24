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
    if (targetPrice <= 0) {
      return 0;
    }
    return (savedAmount / targetPrice).clamp(0.0, 1.0);
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
