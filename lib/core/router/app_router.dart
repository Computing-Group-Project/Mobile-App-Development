import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/finance/screens/dashboard_screen.dart';
import '../../features/finance/screens/add_transaction_screen.dart';
import '../../features/goals/screens/financial_calendar_screen.dart';
import '../../features/goals/screens/savings_goals_screen.dart';
import '../../features/goals/screens/wishlist_planner_screen.dart';
import '../../features/receipt_scanner/screens/scan_receipt_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) =>
          const LoginScreen(), // TODO: Replace with RegisterScreen
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/scan-receipt',
      builder: (context, state) => const ScanReceiptScreen(),
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/goals',
      builder: (context, state) => const SavingsGoalsScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistPlannerScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const FinancialCalendarScreen(),
    ),
    // TODO: Add routes as features are built
    // '/transactions'
    // '/add-transaction'
    // '/scan-receipt'
    // '/budgets'
    // '/groups'
    // '/groups/:id'
    // '/goals'
    // '/wishlist'
    // '/calendar'
    // '/analytics'
    // '/ai-coach'
    // '/settings'
  ],
);
