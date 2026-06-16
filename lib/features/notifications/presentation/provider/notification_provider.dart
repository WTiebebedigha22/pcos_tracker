// lib/features/notifications/presentation/provider/notification_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  // Notification settings
  bool _masterEnabled = true;
  bool get masterEnabled => _masterEnabled;
  
  bool _periodReminders = true;
  bool get periodReminders => _periodReminders;
  
  bool _medicationReminders = true;
  bool get medicationReminders => _medicationReminders;
  
  bool _symptomReminders = false;
  bool get symptomReminders => _symptomReminders;
  
  bool _insightAlerts = true;
  bool get insightAlerts => _insightAlerts;
  
  bool _waterReminders = false;
  bool get waterReminders => _waterReminders;

  NotificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await Future.wait([
        loadNotifications(),
        loadSettings(),
      ]);
    }
    
    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        loadNotifications();
        loadSettings();
      } else {
        _clearData();
      }
    });
  }

  void _clearData() {
    _notifications = [];
    _isLoading = false;
    notifyListeners();
  }

  // Load notifications from Supabase
  Future<void> loadNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      _notifications = (response as List).map((item) => {
        'id': item['id'],
        'title': item['title'],
        'body': item['body'],
        'type': item['type'] ?? 'general',
        'is_read': item['is_read'] ?? false,
        'created_at': DateTime.parse(item['created_at']),
        'data': item['data'],
      }).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load notification settings
  Future<void> loadSettings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response != null) {
        _masterEnabled = response['notifications_enabled'] ?? true;
        _periodReminders = response['period_reminder'] ?? true;
        _medicationReminders = response['medication_reminder'] ?? true;
        // Other settings from user_settings table
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
      
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      _error = e.toString();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);
      
      for (var notification in _notifications) {
        notification['is_read'] = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      _error = e.toString();
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', id);
      
      _notifications.removeWhere((n) => n['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      _error = e.toString();
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', user.id);
      
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      _error = e.toString();
    }
  }

  // Send a notification
  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    if (!_masterEnabled) return;
    
    try {
      final notificationData = {
        'user_id': user.id,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('notifications')
          .insert(notificationData)
          .select()
          .single();
      
      // Add to local list
      _notifications.insert(0, {
        'id': response['id'],
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
        'created_at': DateTime.now(),
        'data': data,
      });
      
      notifyListeners();
      
      // Show local notification - FIXED: Call static method on class
      await NotificationService.showLocalNotification(
        title: title,
        body: body,
        payload: type,
      );
      
    } catch (e) {
      debugPrint('Error sending notification: $e');
      _error = e.toString();
    }
  }

  // Send period reminder
  Future<void> sendPeriodReminder(String title, String body) async {
    if (_periodReminders && _masterEnabled) {
      await sendNotification(
        title: title,
        body: body,
        type: 'cycle',
        data: {'type': 'period_reminder'},
      );
    }
  }

  // Send medication reminder
  Future<void> sendMedicationReminder(String title, String body) async {
    if (_medicationReminders && _masterEnabled) {
      await sendNotification(
        title: title,
        body: body,
        type: 'medication',
        data: {'type': 'medication_reminder'},
      );
    }
  }

  // Send symptom reminder
  Future<void> sendSymptomReminder(String title, String body) async {
    if (_symptomReminders && _masterEnabled) {
      await sendNotification(
        title: title,
        body: body,
        type: 'symptom',
        data: {'type': 'symptom_reminder'},
      );
    }
  }

  // Send insight alert
  Future<void> sendInsightAlert(String title, String body) async {
    if (_insightAlerts && _masterEnabled) {
      await sendNotification(
        title: title,
        body: body,
        type: 'insight',
        data: {'type': 'insight_alert'},
      );
    }
  }

  // Send water reminder
  Future<void> sendWaterReminder(String title, String body) async {
    if (_waterReminders && _masterEnabled) {
      await sendNotification(
        title: title,
        body: body,
        type: 'general',
        data: {'type': 'water_reminder'},
      );
    }
  }

  // Update notification settings
  Future<void> updateSettings({
    bool? masterEnabled,
    bool? periodReminders,
    bool? medicationReminders,
    bool? symptomReminders,
    bool? insightAlerts,
    bool? waterReminders,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      final updates = <String, dynamic>{};
      if (masterEnabled != null) {
        _masterEnabled = masterEnabled;
        updates['notifications_enabled'] = masterEnabled;
      }
      if (periodReminders != null) {
        _periodReminders = periodReminders;
        updates['period_reminder'] = periodReminders;
      }
      if (medicationReminders != null) {
        _medicationReminders = medicationReminders;
        updates['medication_reminder'] = medicationReminders;
      }
      
      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
        
        await _supabase
            .from('user_settings')
            .update(updates)
            .eq('user_id', user.id);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      _error = e.toString();
    }
  }

  // Toggle master notifications
  Future<void> toggleMasterNotifications(bool value) async {
    await updateSettings(masterEnabled: value);
  }

  // Toggle period reminders
  Future<void> togglePeriodReminders(bool value) async {
    await updateSettings(periodReminders: value);
  }

  // Toggle medication reminders
  Future<void> toggleMedicationReminders(bool value) async {
    await updateSettings(medicationReminders: value);
  }

  // Toggle symptom reminders
  Future<void> toggleSymptomReminders(bool value) async {
    _symptomReminders = value;
    notifyListeners();
    // Note: You may want to save this to a separate settings table
  }

  // Toggle insight alerts
  Future<void> toggleInsightAlerts(bool value) async {
    _insightAlerts = value;
    notifyListeners();
  }

  // Toggle water reminders
  Future<void> toggleWaterReminders(bool value) async {
    _waterReminders = value;
    notifyListeners();
  }

  // Get unread count
  int get unreadCount {
    return _notifications.where((n) => n['is_read'] == false).length;
  }

  // Get notifications by type
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  // Get today's notifications
  List<Map<String, dynamic>> getTodayNotifications() {
    final today = DateTime.now();
    return _notifications.where((n) {
      final date = n['created_at'] as DateTime;
      return date.year == today.year &&
             date.month == today.month &&
             date.day == today.day;
    }).toList();
  }

  // Schedule medication reminders - FIXED: Call static method on class
  Future<void> scheduleMedicationReminders(Map<String, dynamic> medication) async {
    if (!_masterEnabled || !_medicationReminders) return;
    
    try {
      // Schedule local notification using static method
      await NotificationService.scheduleDailyNotification(
        id: medication['id'].hashCode,
        title: 'Medication Reminder',
        body: 'Time to take ${medication['name']} (${medication['dosage']})',
        hour: 8,
        minute: 0,
        payload: 'medication_${medication['id']}',
      );
      
      // Send push notification (will be delivered at the scheduled time)
      await sendMedicationReminder(
        'Medication Reminder',
        'Time to take ${medication['name']} (${medication['dosage']})',
      );
    } catch (e) {
      debugPrint('Error scheduling medication reminder: $e');
    }
  }

  // Schedule period reminder
  Future<void> schedulePeriodReminder(DateTime predictedDate) async {
    if (!_masterEnabled || !_periodReminders) return;
    
    final daysUntil = predictedDate.difference(DateTime.now()).inDays;
    if (daysUntil <= 2 && daysUntil > 0) {
      await sendPeriodReminder(
        'Period Starting Soon',
        'Your period is predicted to start in $daysUntil days. Get ready!',
      );
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}