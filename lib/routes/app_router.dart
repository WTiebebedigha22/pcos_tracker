import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pcos_tracker/app.dart';

// Import your shell

// Import your pages
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
      // 1. AUTH ROUTES (Standalone - No Nav Bar)
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // 2. MAIN APP ROUTE (The Shell)
      // When the user hits '/dashboard' (or whatever your home path is), 
      // we load the AppMainScreen which contains the Navigation Bar.
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const AppMainScreen(),
      ),

      /* 
         NOTE: Since your AppMainScreen uses an IndexedStack to manage 
         Cycle, Symptoms, Meds, and Profile internally, you don't 
         necessarily need separate top-level GoRoutes for them if 
         you only navigate via the BottomNavBar.
         
         If you want to be able to deep-link to them (e.g., context.go('/profile')),
         you would typically use a ShellRoute. But for your current 
         AppMainScreen setup, the code above is the "fix."
      */
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