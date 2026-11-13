import 'package:flutter/foundation.dart';

/// Thin wrapper so we can swap Sentry/Crashlytics without touching call sites.
class CrashReporter {
  static Future<void> init() async {
    // TODO: await SentryFlutter.init(...) or FirebaseCrashlytics
    debugPrint('CrashReporter.init (no-op — wire up Sentry)');
  }
  static void capture(Object error, StackTrace? st, {String? hint}) {
    // TODO: Sentry.captureException(error, stackTrace: st, hint: hint);
    debugPrint('Crash: $error $hint');
  }
}
