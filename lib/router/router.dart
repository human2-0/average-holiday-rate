import 'package:average_holiday_rate_pay/customs/page_transistion.dart';
import 'package:average_holiday_rate_pay/ui/add_new_payslip.dart';
import 'package:average_holiday_rate_pay/ui/calendar_history.dart';
import 'package:average_holiday_rate_pay/ui/dashboard/dashboard_layout.dart';
import 'package:average_holiday_rate_pay/ui/main_layout.dart';
import 'package:average_holiday_rate_pay/ui/profile/login_screen.dart';
import 'package:average_holiday_rate_pay/ui/profile/profile.dart';
import 'package:average_holiday_rate_pay/ui/profile/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// app_router.dart

class AppRouter extends ChangeNotifier {
  AppRouter() {
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
          pageBuilder: (context, state) => FadeTransitionPage<void>(
            key: state.pageKey,
            child: const AddPayslipScreen(),
          ),
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
        // Define more routes as needed
      ],
      initialLocation: '/',
      navigatorKey: navigatorKey,
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
  late final GoRouter _router;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  GoRouter get router => _router;
}
