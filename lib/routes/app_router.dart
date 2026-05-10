import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';

import '../features/cycle_tracking/presentation/pages/cycle_calender.dart';
import '../features/dashboard/presentation/pages/dashboard.dart';
import '../features/symptoms/presentation/pages/symptoms_log.dart';
import '../features/medications/presentation/pages/medications.dart';
import '../features/lifestyle/presentation/pages/water_tracker.dart';
import '../features/insights/presentation/pages/insights.dart';
import '../features/profile/presentation/pages/profile_page.dart';

import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.login,
    debugLogDiagnostics: true,

    routes: [
      // AUTH
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // DASHBOARD
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),

      // CYCLE TRACKING
      GoRoute(
        path: RouteNames.cycleCalendar,
        builder: (context, state) => const CycleCalendarPage(),
      ),

      // SYMPTOMS
      GoRoute(
        path: RouteNames.symptoms,
        builder: (context, state) => const SymptomLogPage(),
      ),

      // MEDICATIONS
      GoRoute(
        path: RouteNames.medications,
        builder: (context, state) => const MedicationsPage(),
      ),

      // LIFESTYLE
      GoRoute(
        path: RouteNames.lifestyle,
        builder: (context, state) => const WaterTrackerPage(),
      ),

      // INSIGHTS
      GoRoute(
        path: RouteNames.insights,
        builder: (context, state) => const InsightsPage(),
      ),

      // PROFILE
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text(
            'Page not found: ${state.uri}',
          ),
        ),
      );
    },
  );
}