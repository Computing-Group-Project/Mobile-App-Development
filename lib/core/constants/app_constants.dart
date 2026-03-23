/// App-wide constants. Keep feature-specific constants in their own modules.
class AppConstants {
  AppConstants._();

  static const String appName = 'FundFlow';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';
  static const String budgetsCollection = 'budgets';
  static const String groupsCollection = 'groups';
  static const String goalsCollection = 'goals';
  static const String wishlistCollection = 'wishlist';

  // Default transaction categories
  static const List<String> defaultCategories = [
    'Food & Drinks',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Education',
    'Health',
    'Groceries',
    'Rent',
    'Subscriptions',
    'Other',
  ];

  // Budget limits
  static const int maxCategoryNameLength = 30;
  static const int maxNoteLength = 200;
  static const int maxGroupMembers = 20;
}
