import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/finance/screens/dashboard_screen.dart';
import '../../features/finance/screens/add_transaction_screen.dart';
import '../../features/finance/screens/transaction_history_screen.dart';
import '../../features/finance/screens/budget_manager_screen.dart';
import '../../features/goals/screens/financial_calendar_screen.dart';
import '../../features/goals/screens/savings_goals_screen.dart';
import '../../features/goals/screens/wishlist_planner_screen.dart';
import '../../features/receipt_scanner/screens/scan_receipt_screen.dart';
import '../../features/groups/screens/group_list_screen.dart';
import '../../features/groups/screens/group_dashboard_screen.dart';
import '../../features/groups/screens/create_group_screen.dart';
import '../../features/groups/screens/add_shared_expense_screen.dart';
import '../../features/groups/screens/settle_up_screen.dart';
import '../../features/groups/models/group_model.dart';
import '../../features/groups/screens/settlement_history_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/ai_coach/screens/ai_coach_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../widgets/main_shell.dart';

/// Listens to a stream and triggers GoRouter to re-evaluate redirects.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/ai-coach',
          builder: (context, state) => const AiCoachScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/groups',
          builder: (context, state) => const GroupListScreen(),
        ),
      ],
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
      path: '/transactions',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/budgets',
      builder: (context, state) => const BudgetManagerScreen(),
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
    GoRoute(
      path: '/create-group',
      builder: (context, state) => const CreateGroupScreen(),
    ),
    GoRoute(
      path: '/group-dashboard',
      builder: (context, state) {
        final group = state.extra as GroupModel;
        return GroupDashboardScreen(group: group);
      },
    ),
    GoRoute(
      path: '/add-expense',
      builder: (context, state) {
        final group = state.extra as GroupModel;
        return AddSharedExpenseScreen(group: group);
      },
    ),
    GoRoute(
      path: '/settle-up',
      builder: (context, state) {
        final group = state.extra as GroupModel;
        return SettleUpScreen(group: group);
      },
    ),
    GoRoute(
      path: '/settlement-history',
      builder: (context, state) {
        final group = state.extra as GroupModel;
        return SettlementHistoryScreen(group: group);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
