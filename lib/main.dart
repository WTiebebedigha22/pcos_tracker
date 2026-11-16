import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/local_storage_service.dart';
import 'features/phase_one/phase_one_app.dart';
import 'features/phase_one/phase_one_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  final state = PhaseOneState();
  await state.load();
  runApp(ChangeNotifierProvider.value(
    value: state,
    child: const LunoraPhaseOneApp(),
  ));
}
