import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routes/app_router.dart';
import 'dependency_injection/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gygncpzxyorabgnhnhgl.supabase.co',
    anonKey:
        'sb_publishable_ml_TvJq6NPnm83dwbd7Dqg_FV4QhWOJ',
  );

  // Initialize Dependency Injection
  await initDependencies();

  runApp(
    const MyApp(),
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
    );
  }
}