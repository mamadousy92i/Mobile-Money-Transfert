// lib/providers/agent_provider.dart
import 'package:flutter/material.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';

class AgentProvider with ChangeNotifier {
  final AgentService _agentService;

  List<Agent> _agents = [];
  bool _isLoading = false;
  String? _errorMessage;

  AgentProvider(this._agentService);

  // Getters pour accéder à l'état depuis l'interface
  List<Agent> get agents => _agents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Méthode pour charger les agents
  Future<void> fetchAgents({double? lat, double? lon}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifie l'interface que le chargement a commencé

    try {
      _agents = await _agentService.getAgents(lat: lat, lon: lon);
    } catch (e) {
      _errorMessage = "Impossible de charger les agents. Veuillez réessayer.";
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifie l'interface de la fin du chargement et des nouvelles données
    }
  }
}