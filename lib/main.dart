import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/goals/providers/goals_provider.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase once google-services.json is configured
  // await Firebase.initializeApp();
  runApp(const FundFlowApp());
}

class FundFlowApp extends StatelessWidget {
  const FundFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
      ],
      child: MaterialApp(
        title: 'FundFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const LoginScreen(),
      ),
    );
  }
}
