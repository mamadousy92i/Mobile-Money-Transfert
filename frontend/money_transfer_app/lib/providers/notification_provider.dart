// lib/providers/notification_provider.dart

import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider(this._notificationService);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;


  List<NotificationModel> get notifications => _notifications;

  bool get isLoading => _isLoading;


  String? _activeFilter;


  String? get activeFilter => _activeFilter;

  Future<void> fetchNotifications({String? status}) async {
    _isLoading = true;
    _activeFilter = status;
    notifyListeners();
    try {
      _notifications = await _notificationService.getNotifications(status: status);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners(); // On notifie les widgets pour qu'ils se mettent à jour
    } catch (e) {
      // Gérer l'erreur si nécessaire, mais le service retourne déjà 0
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      // On met à jour l'état local immédiatement pour une meilleure réactivité
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && _notifications[index].isUnread) {
        // On crée une nouvelle instance de la notification avec le statut mis à jour
        final oldNotification = _notifications[index];
        _notifications[index] = NotificationModel(
          id: oldNotification.id,
          title: oldNotification.title,
          message: oldNotification.message,
          notificationType: oldNotification.notificationType,
          createdAt: oldNotification.createdAt,
          readStatus: 'READ', // On change le statut
        );
        _unreadCount--; // On décrémente le compteur
        notifyListeners();
      }

      // Ensuite, on appelle l'API en arrière-plan
      await _notificationService.markAsRead(notificationId);

    } catch (e) {
      // En cas d'erreur, on pourrait annuler le changement local (rollback)
      print("Échec de la mise à jour du statut de la notification: $e");
    }
  }

  Future<bool> deleteNotifications(List<int> ids) async {
    try {
      await _notificationService.deleteNotifications(ids);
      // On met à jour l'état local pour refléter la suppression
      _notifications.removeWhere((n) => ids.contains(n.id));
      await fetchUnreadCount(); // On recalcule le nombre de non lues
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }


}
