// lib/features/notifications/presentation/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _masterNotifications = true;
  
  // Notification settings
  bool _periodReminders = true;
  bool _medicationReminders = true;
  bool _symptomReminders = false;
  bool _insightAlerts = true;
  bool _waterReminders = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadSettings();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      _notifications = (response as List).map((item) => {
        'id': item['id'],
        'title': item['title'],
        'body': item['body'],
        'type': item['type'],
        'is_read': item['is_read'] ?? false,
        'created_at': DateTime.parse(item['created_at']),
        'data': item['data'],
      }).toList();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      // Add mock data for demo
      _addMockNotifications();
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _addMockNotifications() {
    _notifications = [
      {
        'id': '1',
        'title': 'Period Starting Soon',
        'body': 'Your period is predicted to start in 3 days. Get ready!',
        'type': 'cycle',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)),
        'data': null,
      },
      {
        'id': '2',
        'title': 'Medication Reminder',
        'body': 'Time to take your Metformin (500mg)',
        'type': 'medication',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 5)),
        'data': null,
      },
      {
        'id': '3',
        'title': 'New Insight Available',
        'body': 'Your cycle patterns show improvement. Check your insights!',
        'type': 'insight',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 1)),
        'data': null,
      },
      {
        'id': '4',
        'title': 'Time to Log Symptoms',
        'body': 'Don\'t forget to log your symptoms for today',
        'type': 'symptom',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 2)),
        'data': null,
      },
    ];
  }

  Future<void> _loadSettings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    try {
      final response = await Supabase.instance.client
          .from('user_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response != null) {
        setState(() {
          _masterNotifications = response['notifications_enabled'] ?? true;
          _periodReminders = response['period_reminder'] ?? true;
          _medicationReminders = response['medication_reminder'] ?? true;
          _insightAlerts = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
      }
    });
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var notification in _notifications) {
        notification['is_read'] = true;
      }
    });
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;
        
        await Supabase.instance.client
            .from('notifications')
            .delete()
            .eq('user_id', user.id);
        
        setState(() {
          _notifications.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Error clearing notifications: $e');
      }
    }
  }

  Future<void> _updateNotificationSetting(String setting, bool value) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    try {
      await Supabase.instance.client
          .from('user_settings')
          .update({setting: value})
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint('Error updating setting: $e');
    }
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notification Settings',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Master switch for all notifications'),
                  value: _masterNotifications,
                  onChanged: (value) {
                    setStateSheet(() => _masterNotifications = value);
                    setState(() => _masterNotifications = value);
                    _updateNotificationSetting('notifications_enabled', value);
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(),
                
                SwitchListTile(
                  title: const Text('Period Reminders'),
                  subtitle: const Text('Get reminders before your expected period'),
                  value: _periodReminders && _masterNotifications,
                  onChanged: _masterNotifications ? (value) {
                    setStateSheet(() => _periodReminders = value);
                    setState(() => _periodReminders = value);
                    _updateNotificationSetting('period_reminder', value);
                  } : null,
                  activeColor: AppColors.primary,
                ),
                
                SwitchListTile(
                  title: const Text('Medication Reminders'),
                  subtitle: const Text('Daily reminders for medications'),
                  value: _medicationReminders && _masterNotifications,
                  onChanged: _masterNotifications ? (value) {
                    setStateSheet(() => _medicationReminders = value);
                    setState(() => _medicationReminders = value);
                    _updateNotificationSetting('medication_reminder', value);
                  } : null,
                  activeColor: AppColors.primary,
                ),
                
                SwitchListTile(
                  title: const Text('Symptom Reminders'),
                  subtitle: const Text('Daily reminders to log symptoms'),
                  value: _symptomReminders && _masterNotifications,
                  onChanged: _masterNotifications ? (value) {
                    setStateSheet(() => _symptomReminders = value);
                    setState(() => _symptomReminders = value);
                  } : null,
                  activeColor: AppColors.primary,
                ),
                
                SwitchListTile(
                  title: const Text('Insight Alerts'),
                  subtitle: const Text('Get notified about health insights'),
                  value: _insightAlerts && _masterNotifications,
                  onChanged: _masterNotifications ? (value) {
                    setStateSheet(() => _insightAlerts = value);
                    setState(() => _insightAlerts = value);
                  } : null,
                  activeColor: AppColors.primary,
                ),
                
                SwitchListTile(
                  title: const Text('Water Reminders'),
                  subtitle: const Text('Reminders to stay hydrated'),
                  value: _waterReminders && _masterNotifications,
                  onChanged: _masterNotifications ? (value) {
                    setStateSheet(() => _waterReminders = value);
                    setState(() => _waterReminders = value);
                  } : null,
                  activeColor: AppColors.primary,
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) return 'Just now';
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'cycle':
        return Icons.calendar_month;
      case 'medication':
        return Icons.medication;
      case 'symptom':
        return Icons.sick;
      case 'insight':
        return Icons.insights;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'cycle':
        return AppColors.primary;
      case 'medication':
        return Colors.green;
      case 'symptom':
        return Colors.orange;
      case 'insight':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  int get _unreadCount {
    return _notifications.where((n) => n['is_read'] == false).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (_unreadCount > 0)
                      _buildUnreadBanner(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return _NotificationCard(
                              notification: notification,
                              onTap: () => _markAsRead(notification['id']),
                              icon: _getNotificationIcon(notification['type']),
                              iconColor: _getNotificationColor(notification['type']),
                              formattedDate: _formatDate(notification['created_at']),
                            );
                          },
                        ),
                      ),
                    ),
                    if (_notifications.isNotEmpty)
                      _buildClearButton(),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When you receive notifications,\nthey will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showSettingsBottomSheet,
            icon: const Icon(Icons.settings),
            label: const Text('Notification Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.primary, size: 8),
          const SizedBox(width: 8),
          Text(
            '$_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TextButton.icon(
        onPressed: _clearAll,
        icon: const Icon(Icons.delete_outline),
        label: const Text('Clear All Notifications'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final String formattedDate;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read'] == true;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? const Color(0xFFF0F0F0) : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['body'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}