// lib/screens/agents/find_agent_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/agent_model.dart';
import '../../models/reception_model.dart';
import '../../models/withdrawal_request_model.dart';
import '../../providers/agent_provider.dart';
import '../../providers/withdrawal_provider.dart';
import '../withdraw/withdrawal_code_screen.dart';

class FindAgentScreen extends StatefulWidget {
  final Reception? reception;
  const FindAgentScreen({super.key, this.reception});

  @override
  State<FindAgentScreen> createState() => _FindAgentScreenState();
}

class _FindAgentScreenState extends State<FindAgentScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  String? _errorMessage;
  bool _isLoading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fetchAgentsNearby();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchAgentsNearby() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Le service de localisation est désactivé.';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'La permission de localisation est refusée.';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'La permission de localisation est refusée de manière permanente.';
        _isLoading = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });

      await Provider.of<AgentProvider>(context, listen: false)
          .fetchAgents(lat: position.latitude, lon: position.longitude);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible d\'obtenir la position GPS.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // dans la classe _FindAgentScreenState de find_agent_screen.dart

  void _showAgentDetails(Agent agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) { // On utilise ce contexte pour le pop()
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée de glissement
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- PARTIE MANQUANTE RÉ-AJOUTÉE ---
              // En-tête avec nom et statut
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.nomComplet,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Statut Ouvert/Fermé
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: agent.estOuvert
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            agent.estOuvert ? 'OUVERT' : 'FERMÉ',
                            style: TextStyle(
                              color: agent.estOuvert
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Adresse et téléphone
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(agent.adresse, style: const TextStyle(fontSize: 15))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone_outlined, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(agent.telephone, style: const TextStyle(fontSize: 15))),
                ],
              ),
              const SizedBox(height: 32),
              // --- FIN DE LA PARTIE MANQUANTE ---

              // Bouton d'action (avec la logique corrigée)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: agent.estOuvert ? () async {
                    final mainScreenContext = context;
                    Navigator.pop(bottomSheetContext);

                    if (widget.reception == null) return;

                    final request = WithdrawalRequest(
                      agentId: agent.id,
                      amount: widget.reception!.montantAttendu,
                    );

                    final provider = Provider.of<WithdrawalProvider>(mainScreenContext, listen: false);
                    final response = await provider.createWithdrawal(request);

                    if (response != null && mounted) {
                      Navigator.push(
                        mainScreenContext,
                        MaterialPageRoute(
                          builder: (context) => WithdrawalCodeScreen(withdrawal: response),
                        ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(mainScreenContext).showSnackBar(
                        const SnackBar(content: Text('Échec de la demande de retrait.'), backgroundColor: Colors.red),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    agent.estOuvert
                        ? 'RETIRER ${widget.reception?.montantAttendu.toStringAsFixed(2) ?? ''} ${widget.reception?.devise ?? ''}'
                        : 'AGENT FERMÉ',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver un Agent'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: _currentPosition != null ? FloatingActionButton(
        onPressed: () {
          _mapController.move(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            14.0,
          );
        },
        child: const Icon(Icons.my_location),
      ) : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_currentPosition == null) {
      return const Center(child: Text('Impossible de déterminer votre position.'));
    }

    return Consumer<AgentProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.money_transfer_app',
                ),
                MarkerLayer(
                  markers: provider.agents.map((agent) {
                    if (agent.latitude != null && agent.longitude != null) {
                      final lat = double.tryParse(agent.latitude!) ?? 0.0;
                      final lon = double.tryParse(agent.longitude!) ?? 0.0;
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(lat, lon),
                        child: GestureDetector(
                          onTap: () => _showAgentDetails(agent),
                          child: const Icon(Icons.location_on, color: Colors.blueAccent, size: 40),
                        ),
                      );
                    }
                    return null;
                  }).whereType<Marker>().toList(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      child: const Icon(Icons.my_location, color: Colors.redAccent, size: 30),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.blue),
                  title: const Text(
                    'Choisissez un agent sur la carte',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: widget.reception != null
                      ? Text('Pour retirer ${widget.reception!.montantAttendu.toStringAsFixed(2)} ${widget.reception!.devise}')
                      : const Text('Pour effectuer votre retrait.'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}