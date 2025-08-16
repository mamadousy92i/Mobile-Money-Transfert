import 'package:flutter/material.dart';

class NotificationItem {
  final int id;
  final String type;
  final String message;
  final bool urgent;

  NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    this.urgent = false,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = notification.urgent;
    final Color borderColor = isUrgent ? Colors.orange.shade500 : Colors.blue.shade500;
    final Color bgColor = isUrgent ? Colors.orange.shade50 : Colors.blue.shade50;
    final Color iconColor = isUrgent ? Colors.orange.shade600 : Colors.blue.shade600;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.notifications,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          if (isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Urgent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationsSection extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationsSection({
    Key? key,
    required this.notifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrer pour n'afficher que les notifications urgentes ou de type KYC
    final filteredNotifications = notifications
        .where((n) => n.urgent || n.type == 'KYC')
        .take(2)
        .toList();

    if (filteredNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredNotifications
          .map((notification) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NotificationCard(notification: notification),
              ))
          .toList(),
    );
  }
}
