import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';

enum NotificationType {
  appointment,
  message,
  call,
  reminder,
  tip,
  emergency,
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionRoute;
  final Map<String, dynamic>? actionParams;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.actionRoute,
    this.actionParams,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.tip,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      actionRoute: json['action_route'] as String?,
      actionParams: json['action_params'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'data': data,
      'action_route': actionRoute,
      'action_params': actionParams,
    };
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _notifications = [];
  final StreamController<List<NotificationItem>> _notificationsController =
      StreamController<List<NotificationItem>>.broadcast();

  Stream<List<NotificationItem>> get notificationsStream =>
      _notificationsController.stream;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      // Load notifications from Supabase
      final response = await SupabaseService.instance
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      _notifications.clear();
      _notifications.addAll(
        (response as List).map((json) => NotificationItem.fromJson(json)),
      );

      _notificationsController.add(_notifications);
      print('✅ Loaded ${_notifications.length} notifications');
    } catch (e) {
      print('❌ Failed to load notifications: $e');
      // Add some demo notifications if database fails
      _addDemoNotifications();
    }
  }

  void _addDemoNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      NotificationItem(
        id: '1',
        title: 'Appointment Reminder',
        body: 'You have an appointment with Dr. Sarah Johnson in 30 minutes',
        type: NotificationType.appointment,
        createdAt: now.subtract(const Duration(minutes: 5)),
        actionRoute: '/appointments',
      ),
      NotificationItem(
        id: '2',
        title: 'New Message',
        body: 'Dr. Emmanuel Mensah sent you a message',
        type: NotificationType.message,
        createdAt: now.subtract(const Duration(minutes: 15)),
        actionRoute: '/chat',
      ),
      NotificationItem(
        id: '3',
        title: 'Health Tip',
        body: 'Remember to stay hydrated! Drink 8 glasses of water daily.',
        type: NotificationType.tip,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: '4',
        title: 'Lab Results Ready',
        body: 'Your blood test results are now available',
        type: NotificationType.reminder,
        createdAt: now.subtract(const Duration(hours: 2)),
        actionRoute: '/medical-records',
      ),
      NotificationItem(
        id: '5',
        title: 'Prescription Ready',
        body: 'Your prescription is ready for pickup',
        type: NotificationType.reminder,
        createdAt: now.subtract(const Duration(hours: 3)),
        actionRoute: '/prescriptions',
      ),
    ]);
    _notificationsController.add(_notifications);
  }

  Future<void> addNotification(NotificationItem notification) async {
    try {
      // Add to database
      await SupabaseService.instance.from('notifications').insert({
        'id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'type': notification.type.name,
        'created_at': notification.createdAt.toIso8601String(),
        'is_read': notification.isRead,
        'data': notification.data,
        'action_route': notification.actionRoute,
        'action_params': notification.actionParams,
      });

      // Add to local list
      _notifications.insert(0, notification);
      _notificationsController.add(_notifications);
      print('✅ Added notification: ${notification.title}');
    } catch (e) {
      print('❌ Failed to add notification: $e');
      // Add locally anyway
      _notifications.insert(0, notification);
      _notificationsController.add(_notifications);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Update in database
      await SupabaseService.instance
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      // Update locally
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationItem(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          createdAt: _notifications[index].createdAt,
          isRead: true,
          data: _notifications[index].data,
          actionRoute: _notifications[index].actionRoute,
          actionParams: _notifications[index].actionParams,
        );
        _notificationsController.add(_notifications);
      }
    } catch (e) {
      print('❌ Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Update in database
      await SupabaseService.instance
          .from('notifications')
          .update({'is_read': true})
          .eq('is_read', false);

      // Update locally
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = NotificationItem(
            id: _notifications[i].id,
            title: _notifications[i].title,
            body: _notifications[i].body,
            type: _notifications[i].type,
            createdAt: _notifications[i].createdAt,
            isRead: true,
            data: _notifications[i].data,
            actionRoute: _notifications[i].actionRoute,
            actionParams: _notifications[i].actionParams,
          );
        }
      }
      _notificationsController.add(_notifications);
    } catch (e) {
      print('❌ Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // Delete from database
      await SupabaseService.instance
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      // Remove locally
      _notifications.removeWhere((n) => n.id == notificationId);
      _notificationsController.add(_notifications);
    } catch (e) {
      print('❌ Failed to delete notification: $e');
    }
  }

  // Helper methods for creating specific notification types
  Future<void> createAppointmentReminder({
    required String patientId,
    required String doctorName,
    required DateTime appointmentTime,
    required String appointmentId,
  }) async {
    final notification = NotificationItem(
      id: 'appointment_${appointmentId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Appointment Reminder',
      body: 'You have an appointment with $doctorName at ${_formatTime(appointmentTime)}',
      type: NotificationType.appointment,
      createdAt: DateTime.now(),
      actionRoute: '/appointments',
      actionParams: {'appointmentId': appointmentId},
    );
    await addNotification(notification);
  }

  Future<void> createMessageNotification({
    required String recipientId,
    required String senderName,
    required String messagePreview,
    required String chatId,
  }) async {
    final notification = NotificationItem(
      id: 'message_${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Message from $senderName',
      body: messagePreview,
      type: NotificationType.message,
      createdAt: DateTime.now(),
      actionRoute: '/chat',
      actionParams: {'chatId': chatId},
    );
    await addNotification(notification);
  }

  Future<void> createCallNotification({
    required String recipientId,
    required String callerName,
    required String callId,
  }) async {
    final notification = NotificationItem(
      id: 'call_${callId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Incoming Call',
      body: '$callerName is calling you',
      type: NotificationType.call,
      createdAt: DateTime.now(),
      actionRoute: '/consultation-room',
      actionParams: {'callId': callId},
    );
    await addNotification(notification);
  }

  Future<void> createHealthTip({
    required String tip,
    required String category,
  }) async {
    final notification = NotificationItem(
      id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Health Tip: $category',
      body: tip,
      type: NotificationType.tip,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  Future<void> createLabResultNotification({
    required String patientId,
    required String testName,
  }) async {
    final notification = NotificationItem(
      id: 'lab_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Lab Results Ready',
      body: 'Your $testName results are now available',
      type: NotificationType.reminder,
      createdAt: DateTime.now(),
      actionRoute: '/medical-records',
    );
    await addNotification(notification);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void dispose() {
    _notificationsController.close();
  }
}

// Singleton instance
final NotificationService notificationService = NotificationService();
