// lib/services/notification_service.dart

import '../models/notification_model.dart'; // Nous créerons ce modèle juste après
import '../network/api_client.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationModel>> getNotifications({String? status}) async {
    try {
      // On passe le paramètre à l'appel de l'API
      final paginatedResponse = await _apiClient.getNotifications(status: status);
      return paginatedResponse.results;
    } catch (e) {
      print('Erreur dans NotificationService: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.getUnreadNotificationCount();
      return response['unread_count'] ?? 0;
    } catch (e) {
      print('Erreur dans getUnreadCount: $e');
      return 0; // En cas d'erreur, on retourne 0
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Erreur dans markAsRead: $e');
      rethrow;
    }
  }

  Future<void> deleteNotifications(List<int> ids) async {
    try {
      await _apiClient.deleteNotifications({'ids': ids});
    } catch (e) {
      print('Erreur dans deleteNotifications: $e');
      rethrow;
    }
  }
}