import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../../../core/services/demo_data_seeder.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _keyBudgetAlerts = 'notif_budget';
  static const _keyBillReminders = 'notif_bill';
  static const _keyGroupActivity = 'notif_group';

  bool _budgetAlerts = true;
  bool _billReminders = true;
  bool _groupActivity = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budgetAlerts = prefs.getBool(_keyBudgetAlerts) ?? true;
      _billReminders = prefs.getBool(_keyBillReminders) ?? true;
      _groupActivity = prefs.getBool(_keyGroupActivity) ?? true;
    });
  }

  Future<void> _setBudgetAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBudgetAlerts, value);
    setState(() => _budgetAlerts = value);
  }

  Future<void> _setBillReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBillReminders, value);
    setState(() => _billReminders = value);
  }

  Future<void> _setGroupActivity(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGroupActivity, value);
    setState(() => _groupActivity = value);
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System default';
    }
  }

  void _showThemePicker(ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System default'),
              trailing: themeProvider.themeMode == ThemeMode.system
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                themeProvider.setThemeMode('system');
                ctx.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: themeProvider.themeMode == ThemeMode.light
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                themeProvider.setThemeMode('light');
                ctx.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: themeProvider.themeMode == ThemeMode.dark
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                themeProvider.setThemeMode('dark');
                ctx.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Profile',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                (auth.displayName ?? auth.email ?? 'U')[0].toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text(auth.displayName ?? 'User'),
            subtitle: Text(auth.email ?? ''),
          ),
          const Divider(),

          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Appearance',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(themeProvider.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(themeProvider),
          ),
          const Divider(),

          // Notifications section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Notifications',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.savings_outlined),
            title: const Text('Budget alerts'),
            subtitle: const Text('Notify when 80% of a budget is spent'),
            value: _budgetAlerts,
            onChanged: _setBudgetAlerts,
            activeThumbColor: const Color(0xFF01C38D),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.event_outlined),
            title: const Text('Bill reminders'),
            subtitle: const Text('Notify 1 day before a bill is due'),
            value: _billReminders,
            onChanged: _setBillReminders,
            activeThumbColor: const Color(0xFF01C38D),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.group_outlined),
            title: const Text('Group activity'),
            subtitle: const Text('Push notifications for new group expenses'),
            value: _groupActivity,
            onChanged: _setGroupActivity,
            activeThumbColor: const Color(0xFF01C38D),
          ),
          const Divider(),

          // Account section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Account',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Load Demo Data'),
            subtitle: const Text('For testing only — replaces all existing data'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('⚠ Demo Use Only'),
                  content: const Text(
                    'This will DELETE all your existing transactions, goals, budgets, wishlist items and financial events, then replace them with sample data.\n\nThis is intended for testing and demonstration purposes only.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => ctx.pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => ctx.pop(true),
                      child: const Text('Clear & Load Demo'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                try {
                  await DemoDataSeeder().clearAndSeed();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo data loaded')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Log Out',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => ctx.pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => ctx.pop(true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await Provider.of<AuthProvider>(context, listen: false).logout();
                // GoRouter redirect will navigate to /login automatically
              }
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'FundFlow v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
