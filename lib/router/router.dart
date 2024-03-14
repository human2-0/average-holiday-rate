import 'package:average_holiday_rate_pay/customs/page_transistion.dart';
import 'package:average_holiday_rate_pay/providers/auth_provider.dart';
import 'package:average_holiday_rate_pay/providers/settings_provider.dart';
import 'package:average_holiday_rate_pay/ui/add_new_payslip.dart';
import 'package:average_holiday_rate_pay/ui/calendar_history.dart';
import 'package:average_holiday_rate_pay/ui/dashboard/dashboard_layout.dart';
import 'package:average_holiday_rate_pay/ui/main_layout.dart';
import 'package:average_holiday_rate_pay/ui/profile/login_screen.dart';
import 'package:average_holiday_rate_pay/ui/profile/profile.dart';
import 'package:average_holiday_rate_pay/ui/profile/settings_entry.dart';
import 'package:average_holiday_rate_pay/ui/profile/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// app_router.dart

class AppRouter extends ChangeNotifier {


  AppRouter(this._ref) {
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            key: state.pageKey,
            child: const MainLayout(bodyContent: DashboardChartsScreen()),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            key: state.pageKey,
            child: const MainLayout(bodyContent: PayslipHistory()),
          ),
        ),
        GoRoute(
          path: '/addPayslip',
          pageBuilder: (context, state) {
            return FadeTransitionPage(
              key: state.pageKey, // Ensure you provide a unique key
              child: const AddPayslipScreen(), // Your target page widget
            );
          },
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            key: state.pageKey,
            child: const MainLayout(bodyContent: ProfileScreen()),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            key: state.pageKey,
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: '/settings_entry',
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            key: state.pageKey,
            child: const SettingsEntry(),
          ),
        ),
        // Define more routes as needed
      ],
      initialLocation: '/profile',
      redirect: (context,state) {
        final userId = _ref.watch(authStateNotifierProvider)?.uid;

        final isNavigatingToSignUp = state.fullPath == '/signup';

        // If the user is unauthenticated and not trying to navigate to the signup page, redirect to login
        if (userId == null && !isNavigatingToSignUp) {
          return '/login';
        }

        if (userId != null) {
          final userData = _ref.read(userSettingsProvider(userId));

          if (!userData.isLoading) {
            // Assuming there's a way to check if userData is still loading.
            // If userData has finished loading and we have actual settings to check:
            final settings =
                userData.settings; // This is your actual settings object.

            if (settings != null &&
                (settings.payRate == 0 || settings.contractedHours == 0)) {
              // Conditions are met, redirect to settings entry.
              return '/settings_entry';
            }
          }
        }

        return null;

      },
      navigatorKey: navigatorKey,
      debugLogDiagnostics: true,
      errorPageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: Center(child: Text('Error: ${state.error}')),
        ),
      ),
    );
  }

  final Ref _ref;
  late final GoRouter _router;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  GoRouter get router => _router;
}
