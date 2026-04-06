import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/finance/providers/transaction_provider.dart';
import 'features/finance/providers/budget_provider.dart';
import 'features/finance/providers/recurring_transaction_provider.dart';
import 'features/goals/providers/goals_provider.dart';
import 'features/groups/providers/group_provider.dart';
import 'features/ai_coach/providers/ai_coach_provider.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/notifications/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  // If the user is already signed in from a previous session, init FCM now.
  // Otherwise it is called inside AuthProvider.login() / register().
  if (FirebaseAuth.instance.currentUser != null) {
    await FcmService().init();
  }

  runApp(const FundFlowApp());
}

class FundFlowApp extends StatelessWidget {
  const FundFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => RecurringTransactionProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => AiCoachProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp.router(
          title: 'FundFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
