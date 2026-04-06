import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DemoDataSeeder {
  final _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> clearAndSeed() async {
    final uid = _uid;
    if (uid == null) return;
    await _clearUserData(uid);
    await seed();
  }

  Future<void> seed() async {
    final uid = _uid;
    if (uid == null) return;

    await Future.wait([
      _seedTransactions(uid),
      _seedBudgets(uid),
      _seedGoals(uid),
      _seedWishlist(uid),
      _seedFinancialEvents(uid),
    ]);
  }

  Future<void> _clearUserData(String uid) async {
    final collections = [
      'transactions',
      'budgets',
      'goals',
      'goalContributions',
      'wishlist',
      'financialEvents',
      'recurringTransactions',
    ];

    await Future.wait(collections.map((col) async {
      final snap = await _db
          .collection(col)
          .where('userId', isEqualTo: uid)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      if (snap.docs.isNotEmpty) await batch.commit();
    }));
  }

  Future<void> _seedTransactions(String uid) async {
    final now = DateTime.now();

    final transactions = [
      // --- April (current month) ---
      _tx(uid, 'Part-time Salary', 38000, 'income', 'Salary', now.subtract(const Duration(days: 2))),
      _tx(uid, 'Grocery Run', 3200, 'expense', 'Groceries', now.subtract(const Duration(days: 1))),
      _tx(uid, 'Uber Ride', 450, 'expense', 'Transport', now.subtract(const Duration(days: 1))),
      _tx(uid, 'Netflix', 1490, 'expense', 'Subscriptions', now.subtract(const Duration(days: 3))),
      _tx(uid, 'Lunch at Cafe', 850, 'expense', 'Food & Drinks', now.subtract(const Duration(days: 4))),

      // --- March ---
      _tx(uid, 'Part-time Salary', 38000, 'income', 'Salary', now.subtract(const Duration(days: 32))),
      _tx(uid, 'Freelance UI Task', 15000, 'income', 'Freelance', now.subtract(const Duration(days: 20))),
      _tx(uid, 'Hostel Fee', 25000, 'expense', 'Rent', now.subtract(const Duration(days: 35))),
      _tx(uid, 'Grocery Run', 4100, 'expense', 'Groceries', now.subtract(const Duration(days: 28))),
      _tx(uid, 'Bus Pass', 2000, 'expense', 'Transport', now.subtract(const Duration(days: 30))),
      _tx(uid, 'New Shoes', 7500, 'expense', 'Shopping', now.subtract(const Duration(days: 22))),
      _tx(uid, 'Pizza with friends', 1200, 'expense', 'Food & Drinks', now.subtract(const Duration(days: 25))),
      _tx(uid, 'Mobile Plan', 3490, 'expense', 'Bills & Utilities', now.subtract(const Duration(days: 27))),
      _tx(uid, 'Textbooks', 4800, 'expense', 'Education', now.subtract(const Duration(days: 18))),
      _tx(uid, 'Cinema', 1100, 'expense', 'Entertainment', now.subtract(const Duration(days: 15))),
      _tx(uid, 'Pharmacy', 680, 'expense', 'Health', now.subtract(const Duration(days: 12))),
      _tx(uid, 'Spotify', 699, 'expense', 'Subscriptions', now.subtract(const Duration(days: 10))),
      _tx(uid, 'Restaurant dinner', 2800, 'expense', 'Food & Drinks', now.subtract(const Duration(days: 8))),

      // --- February ---
      _tx(uid, 'Scholarship Payment', 20000, 'income', 'Scholarship', now.subtract(const Duration(days: 55))),
      _tx(uid, 'Part-time Salary', 38000, 'income', 'Salary', now.subtract(const Duration(days: 62))),
      _tx(uid, 'Hostel Fee', 25000, 'expense', 'Rent', now.subtract(const Duration(days: 65))),
      _tx(uid, 'Grocery Run', 3800, 'expense', 'Groceries', now.subtract(const Duration(days: 58))),
      _tx(uid, 'Bus Pass', 2000, 'expense', 'Transport', now.subtract(const Duration(days: 60))),
      _tx(uid, 'Clothes', 8000, 'expense', 'Shopping', now.subtract(const Duration(days: 50))),
      _tx(uid, 'Mobile Plan', 3490, 'expense', 'Bills & Utilities', now.subtract(const Duration(days: 57))),
      _tx(uid, 'Study materials', 2200, 'expense', 'Education', now.subtract(const Duration(days: 45))),
      _tx(uid, 'Doctor visit', 1500, 'expense', 'Health', now.subtract(const Duration(days: 48))),
      _tx(uid, 'Netflix', 1490, 'expense', 'Subscriptions', now.subtract(const Duration(days: 40))),
    ];

    final batch = _db.batch();
    for (final t in transactions) {
      batch.set(_db.collection('transactions').doc(), t);
    }
    await batch.commit();
  }

  Map<String, dynamic> _tx(String uid, String title, double amount,
      String type, String category, DateTime date) {
    return {
      'userId': uid,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isRecurring': false,
      'notes': null,
    };
  }

  Future<void> _seedBudgets(String uid) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final budgets = [
      {
        'userId': uid,
        'name': 'Food Budget',
        'limit': 10000.0,
        'startDate': Timestamp.fromDate(monthStart),
        'endDate': Timestamp.fromDate(monthEnd),
        'categories': ['Food & Drinks', 'Groceries'],
      },
      {
        'userId': uid,
        'name': 'Transport',
        'limit': 5000.0,
        'startDate': Timestamp.fromDate(monthStart),
        'endDate': Timestamp.fromDate(monthEnd),
        'categories': ['Transport'],
      },
      {
        'userId': uid,
        'name': 'Entertainment',
        'limit': 3000.0,
        'startDate': Timestamp.fromDate(monthStart),
        'endDate': Timestamp.fromDate(monthEnd),
        'categories': ['Entertainment', 'Subscriptions'],
      },
    ];

    final batch = _db.batch();
    for (final b in budgets) {
      batch.set(_db.collection('budgets').doc(), b);
    }
    await batch.commit();
  }

  Future<void> _seedGoals(String uid) async {
    final now = DateTime.now();

    final goals = [
      {
        'userId': uid,
        'title': 'New Laptop',
        'targetAmount': 320000.0,
        'currentAmount': 124000.0,
        'targetDate': Timestamp.fromDate(now.add(const Duration(days: 160))),
        'iconKey': 'laptop',
      },
      {
        'userId': uid,
        'title': 'Emergency Fund',
        'targetAmount': 150000.0,
        'currentAmount': 54000.0,
        'targetDate': Timestamp.fromDate(now.add(const Duration(days: 220))),
        'iconKey': 'shield',
      },
      {
        'userId': uid,
        'title': 'Semester Break Trip',
        'targetAmount': 90000.0,
        'currentAmount': 34000.0,
        'targetDate': Timestamp.fromDate(now.add(const Duration(days: 95))),
        'iconKey': 'flight',
      },
    ];

    for (final g in goals) {
      final goalRef = _db.collection('goals').doc();
      await goalRef.set(g);

      // seed a couple of contributions per goal
      final contributions = [
        {
          'userId': uid,
          'goalId': goalRef.id,
          'amount': (g['currentAmount'] as double) * 0.6,
          'date': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
          'note': 'Initial deposit',
        },
        {
          'userId': uid,
          'goalId': goalRef.id,
          'amount': (g['currentAmount'] as double) * 0.4,
          'date': Timestamp.fromDate(now.subtract(const Duration(days: 8))),
          'note': 'Monthly top-up',
        },
      ];
      final batch = _db.batch();
      for (final c in contributions) {
        batch.set(_db.collection('goalContributions').doc(), c);
      }
      await batch.commit();
    }
  }

  Future<void> _seedWishlist(String uid) async {
    final now = DateTime.now();

    final items = [
      {
        'userId': uid,
        'name': 'Noise Cancelling Headphones',
        'targetPrice': 68000.0,
        'savedAmount': 22000.0,
        'priority': 'high',
        'desiredBy': Timestamp.fromDate(now.add(const Duration(days: 130))),
      },
      {
        'userId': uid,
        'name': 'Smart Watch',
        'targetPrice': 42000.0,
        'savedAmount': 9000.0,
        'priority': 'medium',
        'desiredBy': Timestamp.fromDate(now.add(const Duration(days: 110))),
      },
      {
        'userId': uid,
        'name': 'Used Bicycle',
        'targetPrice': 55000.0,
        'savedAmount': 12000.0,
        'priority': 'low',
        'desiredBy': Timestamp.fromDate(now.add(const Duration(days: 190))),
      },
    ];

    final batch = _db.batch();
    for (final item in items) {
      batch.set(_db.collection('wishlist').doc(), item);
    }
    await batch.commit();
  }

  Future<void> _seedFinancialEvents(String uid) async {
    final now = DateTime.now();

    final events = [
      {
        'userId': uid,
        'title': 'Hostel Fee',
        'amount': 25000.0,
        'type': 'bill',
        'date': Timestamp.fromDate(DateTime(now.year, now.month, 28)),
        'note': null,
      },
      {
        'userId': uid,
        'title': 'Mobile Plan',
        'amount': 3490.0,
        'type': 'bill',
        'date': Timestamp.fromDate(DateTime(now.year, now.month + 1, 6)),
        'note': null,
      },
      {
        'userId': uid,
        'title': 'App Subscriptions',
        'amount': 2189.0,
        'type': 'bill',
        'date': Timestamp.fromDate(DateTime(now.year, now.month + 1, 12)),
        'note': 'Netflix + Spotify',
      },
      {
        'userId': uid,
        'title': 'Part-time Salary',
        'amount': 38000.0,
        'type': 'income',
        'date': Timestamp.fromDate(DateTime(now.year, now.month, 30)),
        'note': null,
      },
      {
        'userId': uid,
        'title': 'Scholarship Payment',
        'amount': 20000.0,
        'type': 'income',
        'date': Timestamp.fromDate(DateTime(now.year, now.month + 1, 15)),
        'note': null,
      },
    ];

    final batch = _db.batch();
    for (final e in events) {
      batch.set(_db.collection('financialEvents').doc(), e);
    }
    await batch.commit();
  }
}
