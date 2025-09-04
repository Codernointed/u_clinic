import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Appointment Reminder',
      message:
          'Your appointment with Dr. Sarah Johnson is tomorrow at 10:00 AM',
      type: NotificationType.appointment,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      title: 'Health Tip',
      message:
          'Stay hydrated! Drink at least 8 glasses of water daily for better health.',
      type: NotificationType.healthTip,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
    ),
    NotificationItem(
      title: 'Lab Results Available',
      message: 'Your blood test results are now available. Click to view.',
      type: NotificationType.labResult,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
    ),
    NotificationItem(
      title: 'Prescription Refill Due',
      message: 'Your prescription for Amoxicillin needs to be refilled soon.',
      type: NotificationType.prescription,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    NotificationItem(
      title: 'Health Event',
      message: 'Mental Health Awareness Week starts next Monday. Register now!',
      type: NotificationType.event,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      isRead: true,
    ),
    NotificationItem(
      title: 'Emergency Alert',
      message: 'Campus clinic will be closed tomorrow due to maintenance.',
      type: NotificationType.emergency,
      timestamp: DateTime.now().subtract(const Duration(hours: 24)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, color: AppColors.primary),
            tooltip: 'Mark All as Read',
          ),
          IconButton(
            onPressed: _showNotificationSettings,
            icon: const Icon(Icons.settings, color: AppColors.primary),
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNotificationStats(),
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStats() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have $unreadCount unread notifications',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Stay updated with your health information',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No notifications yet',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'You\'ll see important updates here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      itemCount: _notifications.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.hashCode.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: AppColors.emergency,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification.title} dismissed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: notification.isRead
                ? AppColors.divider
                : AppColors.primary.withValues(alpha: 0.3),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification.type),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: notification.isRead
                                ? AppColors.textPrimary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    notification.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Row(
                    children: [
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (notification.type == NotificationType.appointment)
                        TextButton(
                          onPressed: () => _viewAppointment(notification),
                          child: const Text('View'),
                        ),
                      if (notification.type == NotificationType.labResult)
                        TextButton(
                          onPressed: () => _viewLabResults(notification),
                          child: const Text('View Results'),
                        ),
                      if (notification.type == NotificationType.prescription)
                        TextButton(
                          onPressed: () => _refillPrescription(notification),
                          child: const Text('Refill'),
                        ),
                      if (notification.type == NotificationType.event)
                        TextButton(
                          onPressed: () => _registerForEvent(notification),
                          child: const Text('Register'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.appointment:
        icon = Icons.calendar_today;
        color = AppColors.cardAppointment;
        break;
      case NotificationType.healthTip:
        icon = Icons.lightbulb;
        color = AppColors.cardConsultation;
        break;
      case NotificationType.labResult:
        icon = Icons.science;
        color = AppColors.cardLabResult;
        break;
      case NotificationType.prescription:
        icon = Icons.medication;
        color = AppColors.cardPrescription;
        break;
      case NotificationType.event:
        icon = Icons.event;
        color = AppColors.primary;
        break;
      case NotificationType.emergency:
        icon = Icons.emergency;
        color = AppColors.emergency;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Appointment Reminders'),
              subtitle: const Text('Get notified about upcoming appointments'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Health Tips'),
              subtitle: const Text('Receive daily health tips and advice'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Lab Results'),
              subtitle: const Text('Get notified when results are available'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Prescription Alerts'),
              subtitle: const Text('Reminders for prescription refills'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Health Events'),
              subtitle: const Text('Updates about campus health events'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Emergency Alerts'),
              subtitle: const Text('Important campus health announcements'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings saved'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _viewAppointment(NotificationItem notification) {
    // TODO: Navigate to appointment details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viewing appointment details...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _viewLabResults(NotificationItem notification) {
    // TODO: Navigate to lab results
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viewing lab results...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _refillPrescription(NotificationItem notification) {
    // TODO: Navigate to prescription refill
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing prescription refill...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _registerForEvent(NotificationItem notification) {
    // TODO: Navigate to event registration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening event registration...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

enum NotificationType {
  appointment,
  healthTip,
  labResult,
  prescription,
  event,
  emergency,
}
