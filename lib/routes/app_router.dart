import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pcos_tracker/app.dart';

import '../features/auth/presentation/pages/forgot_password.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password.dart';
import '../features/cycle_tracking/presentation/pages/add_period.dart';
import '../features/data management/presentation/pages/export_data.dart';
import '../features/data management/presentation/pages/import_data.dart';
import '../features/help/presentation/pages/about_page.dart';
import '../features/insights/presentation/pages/insight_detail.dart';
import '../features/lifestyle/presentation/pages/lifestyle.dart';
import '../features/medications/presentation/pages/edit_meds.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/settings/presentation/pages/change_password.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/dashboard/presentation/pages/dashboard.dart';
import '../features/cycle_tracking/presentation/pages/cycle_calender.dart';
import '../features/symptoms/presentation/pages/symptoms_log.dart';
import '../features/symptoms/presentation/pages/symptoms_history.dart';
import '../features/medications/presentation/pages/medications.dart';
import '../features/lifestyle/presentation/pages/water_tracker.dart';
import '../features/lifestyle/presentation/pages/sleep_tracker.dart';
import '../features/lifestyle/presentation/pages/weight_tracker.dart';
import '../features/lifestyle/presentation/pages/mood_tracker.dart';
import '../features/insights/presentation/pages/insights.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/help/presentation/pages/help_page.dart';
import '../features/help/presentation/pages/privacy_policy_page.dart';
import '../features/help/presentation/pages/terms_of_service_page.dart';

import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    
    redirect: (context, state) {
      final uri = state.uri;
      
      // Handle password reset deep link
      if (uri.toString().contains('reset-password')) {
        return RouteNames.resetPassword;
      }
      
      // You can add more redirect logic here
      // For example, redirect to login if not authenticated
      
      return null;
    },

    routes: [
      // ============================================
      // AUTH ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // ============================================
      // MAIN APP ROUTE (With Bottom Nav)
      // ============================================
      GoRoute(
        path: RouteNames.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const AppMainScreen(),
      ),

      // ============================================
      // CYCLE TRACKING ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.cycleCalendar,
        name: RouteNames.cycleCalendar,
        builder: (context, state) => const CycleCalendarPage(),
      ),
      GoRoute(
        path: RouteNames.addPeriod,
        name: RouteNames.addPeriod,
        builder: (context, state) => const AddPeriodPage(),
      ),

      // ============================================
      // SYMPTOMS ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.symptoms,
        name: RouteNames.symptoms,
        builder: (context, state) => const SymptomLogPage(),
      ),
      GoRoute(
        path: RouteNames.symptomsLog,
        name: RouteNames.symptomsLog,
        builder: (context, state) => const SymptomLogPage(),
      ),
      GoRoute(
        path: RouteNames.symptomsHistory,
        name: RouteNames.symptomsHistory,
        builder: (context, state) => const SymptomsHistoryPage(),
      ),

      // ============================================
      // MEDICATIONS ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.medications,
        name: RouteNames.medications,
        builder: (context, state) => const MedsPage(),
      ),
      GoRoute(
        path: RouteNames.addMedication,
        name: RouteNames.addMedication,
        builder: (context, state) => const MedsPage(),
      ),
      GoRoute(
        path: '${RouteNames.editMedication}/:id',
        name: RouteNames.editMedication,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return EditMedicationPage(medicationId: id ?? '',);
        },
      ),

      // ============================================
      // LIFESTYLE ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.lifestyle,
        name: RouteNames.lifestyle,
        builder: (context, state) => const LifestylePage(),
      ),
      GoRoute(
        path: RouteNames.waterTracker,
        name: RouteNames.waterTracker,
        builder: (context, state) => const WaterTrackerPage(),
      ),
      GoRoute(
        path: RouteNames.sleepTracker,
        name: RouteNames.sleepTracker,
        builder: (context, state) => const SleepTrackerPage(),
      ),
      GoRoute(
        path: RouteNames.weightTracker,
        name: RouteNames.weightTracker,
        builder: (context, state) => const WeightTrackerPage(),
      ),
      GoRoute(
        path: RouteNames.moodTracker,
        name: RouteNames.moodTracker,
        builder: (context, state) => const MoodTrackerPage(),
      ),

      // ============================================
      // INSIGHTS ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.insights,
        name: RouteNames.insights,
        builder: (context, state) => const InsightsPage(),
      ),
      GoRoute(
        path: '${RouteNames.insightsDetail}/:type',
        name: RouteNames.insightsDetail,
        builder: (context, state) {
          final type = state.pathParameters['type'];
          return InsightsDetailPage(insightType: type ?? '',);
        },
      ),

      // ============================================
      // PROFILE ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        name: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),

      // ============================================
      // NOTIFICATIONS ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),

      // ============================================
      // HELP & SUPPORT ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.help,
        name: RouteNames.help,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        name: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: RouteNames.termsOfService,
        name: RouteNames.termsOfService,
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        path: RouteNames.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutPage(),
      ),

      // ============================================
      // DATA MANAGEMENT ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.exportData,
        name: RouteNames.exportData,
        builder: (context, state) => const ExportDataPage(),
      ),
      GoRoute(
        path: RouteNames.importData,
        name: RouteNames.importData,
        builder: (context, state) => const ImportDataPage(),
      ),
    ],

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.uri}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to dashboard on error
                  context.go(RouteNames.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B3FD9),
                ),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    },
  );
}