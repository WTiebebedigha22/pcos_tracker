import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final appLoadingProvider =
    StateProvider<bool>(
  (ref) => false,
);

final selectedBottomNavProvider =
    StateProvider<int>(
  (ref) => 0,
);