class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String iconKey;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.iconKey,
  });

  double get progress {
    if (targetAmount <= 0) {
      return 0;
    }
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? iconKey,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      iconKey: iconKey ?? this.iconKey,
    );
  }
}
