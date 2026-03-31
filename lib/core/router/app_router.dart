import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/finance/screens/dashboard_screen.dart';
import '../../features/finance/screens/add_transaction_screen.dart';
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
    GoRoute(
      path: '/groups',
      builder: (context, state) => const GroupListScreen(),
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
  ],
);
