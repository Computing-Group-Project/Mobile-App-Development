import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/finance/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const LoginScreen(), // TODO: Replace with RegisterScreen
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
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
