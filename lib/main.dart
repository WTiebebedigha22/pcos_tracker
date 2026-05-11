import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dependency_injection/injector.dart';
import 'features/cycle_tracking/presentation/provider/cycle_provider.dart';
import 'features/insights/presentation/provider/insight_provider.dart';
import 'features/lifestyle/presentation/provider/lifestyle_provider.dart';
import 'features/medications/presentation/provider/medication_provider.dart';
import 'features/profile/presentation/provider/profile_provider.dart';
import 'features/symptoms/presentation/provider/symptoms_provider.dart';
import 'routes/app_router.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SUPABASE INITIALIZATION
  await Supabase.initialize(
    url: 'https://gygncpzxyorabgnhnhgl.supabase.co',

    anonKey:
        'sb_publishable_ml_TvJq6NPnm83dwbd7Dqg_FV4QhWOJ',
  );

  // DEPENDENCY INJECTION
  await initDependencies();

  runApp(
    MultiProvider(
      providers: [
        // AUTH
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // DASHBOARD
        ChangeNotifierProvider(
          create: (_) =>
              DashboardProvider(),
        ),

        // CYCLE TRACKING
        ChangeNotifierProvider(
          create: (_) => CycleProvider(),
        ),

        // SYMPTOMS
        ChangeNotifierProvider(
          create: (_) =>
              SymptomProvider(),
        ),

        // MEDICATIONS
        ChangeNotifierProvider(
          create: (_) =>
              MedicationProvider(),
        ),

        // LIFESTYLE
        ChangeNotifierProvider(
          create: (_) =>
              LifestyleProvider(),
        ),

        // INSIGHTS
        ChangeNotifierProvider(
          create: (_) =>
              InsightsProvider(),
        ),

        // PROFILE
        ChangeNotifierProvider(
          create: (_) =>
              ProfileProvider(),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CycleSync',

      debugShowCheckedModeBanner: false,

      routerConfig: AppRouter.router,

      themeMode: ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
            const Color(0xFFFFF7FC),

        fontFamily: 'Poppins',

        colorScheme: ColorScheme.fromSeed(
          seedColor:
              Colors.deepPurpleAccent,
        ),
      ),
    );
  }
}