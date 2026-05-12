import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dependency_injection/injector.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cycle_tracking/presentation/provider/cycle_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/insights/presentation/provider/insight_provider.dart';
import 'features/lifestyle/presentation/provider/lifestyle_provider.dart';
import 'features/medications/presentation/provider/medication_provider.dart';
import 'features/profile/presentation/provider/profile_provider.dart';
import 'features/symptoms/presentation/provider/symptoms_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gygncpzxyorabgnhnhgl.supabase.co',
    anonKey: 'sb_publishable_ml_TvJq6NPnm83dwbd7Dqg_FV4QhWOJ',
  );

  // Initialize Dependency Injection
  await initDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => SymptomProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => LifestyleProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CycleSync',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF7FC),
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          primary: const Color(0xFF8B3FD9), // Matching your dashboard UI
        ),
      ),
    );
  }
}