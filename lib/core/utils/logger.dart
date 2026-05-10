import 'dart:developer';

class Logger {
  static void info(
    String message,
  ) {
    log(
      message,
      name: 'INFO',
    );
  }

  static void warning(
    String message,
  ) {
    log(
      message,
      name: 'WARNING',
    );
  }

  static void error(
    String message,
  ) {
    log(
      message,
      name: 'ERROR',
    );
  }
}