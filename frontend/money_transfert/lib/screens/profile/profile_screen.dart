import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile.dart';
import '../../models/user.dart';
import '../../models/kyc_document.dart';
import '../../models/beneficiary.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/ui/button.dart';
import '../../services/api/auth_api.dart';
import '../../services/api_service.dart';
import 'profile_header.dart';
import 'kyc_status_card.dart';
import 'user_stats_cards.dart';
import 'contact_info_card.dart';
import 'beneficiaries_card.dart';
import 'security_settings_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;
  late List<KycDocument> _kycDocuments;
  late List<Beneficiary> _beneficiaries;
  late List<SecuritySetting> _securitySettings;
  String _currentTab = 'profile';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch real user data from API
      final authApi = ApiService.getAuthApi();
      final userData = await authApi.getUserProfile();
      
      // Convert User model to UserProfile model
      _user = UserProfile(
        id: userData.id,
        firstName: userData.firstName,
        lastName: userData.lastName,
        email: userData.email,
        phoneNumber: userData.phone,
        profilePicture: null, // Add if available in your API
        memberSince: userData.memberSince,
        verificationLevel: userData.verificationLevel,
        kycStatus: userData.kycStatus,
        documentsSubmitted: 0, // Update with real data if available
        documentsRequired: 3, // Update with real data if available
        totalTransactions: 0, // Update with real data if available
        totalSent: '€0', // Update with real data if available
      );
      
      // Initialize other data
      _initializeKycDocuments();
      _initializeBeneficiaries();
      _initializeSecuritySettings();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les données du profil. Veuillez réessayer.';
        // Fallback to default profile if API fails
        _user = UserProfile.defaultProfile();
        _initializeKycDocuments();
        _initializeBeneficiaries();
        _initializeSecuritySettings();
      });
    }
  }

  void _initializeKycDocuments() {
    if (_user == null) return;
    
    _kycDocuments = [
      KycDocument(
        id: 1,
        type: 'ID_CARD',
        name: 'Carte d\'identité',
        status: _user!.kycStatus == 'VERIFIED' ? 'VERIFIED' : _user!.kycStatus == 'PENDING' ? 'PENDING' : 'NOT_SUBMITTED',
        uploadDate: '2025-01-15',
      ),
      KycDocument(
        id: 2,
        type: 'PROOF_ADDRESS',
        name: 'Justificatif de domicile',
        status: _user!.kycStatus == 'VERIFIED' ? 'VERIFIED' : 'PENDING',
        uploadDate: '2025-01-18',
      ),
      KycDocument(
        id: 3,
        type: 'SELFIE',
        name: 'Photo avec pièce d\'identité',
        status: _user!.kycStatus == 'VERIFIED' ? 'VERIFIED' : 'NOT_SUBMITTED',
        uploadDate: _user!.kycStatus == 'VERIFIED' ? '2025-01-19' : null,
      ),
    ];
  }

  void _initializeBeneficiaries() {
    _beneficiaries = [
      Beneficiary(
        id: 1,
        name: 'Marie Dubois',
        phone: '+33 6 12 34 56 78',
        country: 'France',
        flag: '🇫🇷',
        lastUsed: '2025-01-18',
        favorite: true,
      ),
      Beneficiary(
        id: 2,
        name: 'John Smith',
        phone: '+1 234 567 8900',
        country: 'États-Unis',
        flag: '🇺🇸',
        lastUsed: '2025-01-15',
      ),
      Beneficiary(
        id: 3,
        name: 'Sarah Johnson',
        phone: '+44 20 1234 5678',
        country: 'Royaume-Uni',
        flag: '🇬🇧',
        lastUsed: '2025-01-10',
        favorite: true,
      ),
    ];
  }

  void _initializeSecuritySettings() {
    _securitySettings = [
      SecuritySetting(
        id: 'biometric',
        label: 'Authentification biométrique',
        description: 'Empreinte digitale, Face ID',
        enabled: true,
      ),
      SecuritySetting(
        id: 'sms_alerts',
        label: 'Alertes SMS',
        description: 'Notifications pour chaque transaction',
        enabled: true,
      ),
      SecuritySetting(
        id: 'email_alerts',
        label: 'Alertes email',
        description: 'Rapports hebdomadaires par email',
        enabled: false,
      ),
      SecuritySetting(
        id: 'location_tracking',
        label: 'Géolocalisation',
        description: 'Vérification de localisation pour la sécurité',
        enabled: true,
      ),
    ];
  }

  void _handleTabChange(String tab) {
    setState(() {
      _currentTab = tab;
    });
    
    // Navigation vers l'écran correspondant
    switch (tab) {
      case 'home':
        context.go('/home');
        break;
      case 'profile':
        // Déjà sur l'écran de profil
        break;
      case 'transfer':
        // À implémenter ultérieurement
        break;
      case 'agents':
        // À implémenter ultérieurement
        break;
      case 'history':
        // À implémenter ultérieurement
        break;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Dans un cas réel, on appellerait le service d'authentification
              context.go('/auth');
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _user == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          
                          // En-tête du profil
                          ProfileHeader(user: _user!),
                          const SizedBox(height: 24),
                          
                          // Carte de statut KYC
                          KycStatusCard(user: _user!, documents: _kycDocuments),
                          const SizedBox(height: 24),
                          
                          // Cartes de statistiques
                          UserStatsCards(user: _user!),
                          const SizedBox(height: 24),
                          
                          // Informations de contact
                          ContactInfoCard(user: _user!),
                          const SizedBox(height: 24),
                          
                          // Bénéficiaires récents
                          BeneficiariesCard(beneficiaries: _beneficiaries),
                          const SizedBox(height: 24),
                          
                          // Paramètres de sécurité
                          SecuritySettingsCard(
                            settings: _securitySettings,
                            onSettingChanged: (id, value) {
                              // Dans un cas réel, on mettrait à jour les paramètres via l'API
                              debugPrint('Paramètre $id changé à $value');
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Boutons d'action
                          CustomButton(
                            variant: ButtonVariant.outline,
                            width: double.infinity,
                            height: 48,
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor: Colors.white,
                            textColor: Theme.of(context).primaryColor,
                            borderColor: Theme.of(context).primaryColor.withOpacity(0.3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                const Text('Recommander à un ami'),
                              ],
                            ),
                            onPressed: () {
                              // Action de recommandation
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          CustomButton(
                            variant: ButtonVariant.outline,
                            width: double.infinity,
                            height: 48,
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor: Colors.white,
                            textColor: Colors.red.shade600,
                            borderColor: Colors.red.shade200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 20,
                                  color: Colors.red.shade600,
                                ),
                                const SizedBox(width: 8),
                                const Text('Se déconnecter'),
                              ],
                            ),
                            onPressed: _handleLogout,
                          ),
                          const SizedBox(height: 24),
                          
                          // Version de l'application
                          Text(
                            'MoneyTransfer v2.1.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            'Tous droits réservés 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 80), // Espace pour la barre de navigation
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onTabChange: _handleTabChange,
      ),
    );
  }
}
