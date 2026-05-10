class AnalyticsService {
  static void logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) {
    // Integrate Firebase Analytics or Mixpanel later
    print('Event Logged: $name');
    print(parameters);
  }

  static void logScreenView(
    String screenName,
  ) {
    print('Screen Viewed: $screenName');
  }
}