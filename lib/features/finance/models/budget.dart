// Budget model for the finance module
class Budget {
  final String id;
  final String name;
  final double limit;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> categories;

  Budget({
    required this.id,
    required this.name,
    required this.limit,
    required this.startDate,
    required this.endDate,
    required this.categories,
  });
}