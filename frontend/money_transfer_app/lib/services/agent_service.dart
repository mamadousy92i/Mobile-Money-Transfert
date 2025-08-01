// lib/services/agent_service.dart
import '../models/agent_model.dart';
import '../models/paginated_response.dart';
import '../network/api_client.dart';

class AgentService {
  final ApiClient _apiClient;

  AgentService(this._apiClient);

  Future<List<Agent>> getAgents({double? lat, double? lon}) async {
    try {
      // 1. Reçoit la réponse brute (non-typée)
      final dynamic rawResponse = await _apiClient.getAgents(lat: lat, lon: lon);

      // --- AJOUTEZ CE PRINT POUR VOIR LE JSON BRUT ---
      print('>>> JSON BRUT REÇU POUR LES AGENTS: $rawResponse');
      // ---------------------------------------------

      // 2. On reconvertit manuellement pour que le reste de l'app fonctionne
      final paginatedResponse = PaginatedResponse<Agent>.fromJson(
        rawResponse,
            (json) => Agent.fromJson(json as Map<String, dynamic>),
      );

      return paginatedResponse.results;
    } catch (e) {
      print('Erreur dans AgentService: $e');
      rethrow;
    }
  }
}