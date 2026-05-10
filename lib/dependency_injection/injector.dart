import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../core/network/network_info.dart';
import '../core/network/api_client.dart';

import '../core/services/supabase_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/theme_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //! ------------------------------------------------
  //! External
  //! ------------------------------------------------

  sl.registerLazySingleton(
    () => Connectivity(),
  );

  //! ------------------------------------------------
  //! Core
  //! ------------------------------------------------

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(),
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ConnectivityService(),
  );

  sl.registerLazySingleton(
    () => ThemeService(),
  );

  //! ------------------------------------------------
  //! Services
  //! ------------------------------------------------

  sl.registerLazySingleton(
    () => SupabaseService(),
  );

  sl.registerLazySingleton(
    () => LocalStorageService(),
  );

  sl.registerLazySingleton(
    () => NotificationService(),
  );
