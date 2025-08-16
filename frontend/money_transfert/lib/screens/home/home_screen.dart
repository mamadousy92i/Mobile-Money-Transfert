import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/home/header_balance_card.dart';
import '../../widgets/home/notification_card.dart' as notification_widget;
import '../../widgets/home/quick_actions.dart' as quick_actions_widget;
import '../../widgets/home/nearby_agents.dart' as nearby_agents_widget;
import '../../widgets/home/exchange_rates_card.dart' as exchange_rates_widget;
import '../../widgets/home/recent_transactions.dart' as recent_transactions_widget;

// Import du modèle TransactionItem
import '../../models/transaction_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTab = 'home';
  
  // Données simulées pour les notifications
  late List<notification_widget.NotificationItem> _notifications;
  
  // Données simulées pour les actions rapides
  late List<quick_actions_widget.QuickActionItem> _quickActions;
  
  // Données simulées pour les agents à proximité
  late List<nearby_agents_widget.AgentItem> _nearbyAgents;
  
  // Données simulées pour les taux de change
  late List<exchange_rates_widget.CurrencyRate> _exchangeRates;
  
  // Données simulées pour les transactions récentes
  late List<recent_transactions_widget.TransactionItem> _recentTransactions;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialisation des notifications
    _notifications = [
      notification_widget.NotificationItem(
        id: 1,
        type: 'KYC',
        message: 'Vérification KYC en cours - Délai 24-48h',
        urgent: false,
      ),
      notification_widget.NotificationItem(
        id: 2,
        type: 'TRANSACTION',
        message: 'Transaction de €250 vers Marie reçue avec succès',
        urgent: false,
      ),
    ];

    // Initialisation des actions rapides
    _quickActions = [
      quick_actions_widget.QuickActionItem(
        id: 'send',
        label: 'Envoyer',
        icon: Icons.arrow_upward,
        startColor: Colors.blue.shade500,
        endColor: Colors.blue.shade600,
        description: 'Local & International',
      ),
      quick_actions_widget.QuickActionItem(
        id: 'receive',
        label: 'Recevoir',
        icon: Icons.arrow_downward,
        startColor: Colors.green.shade500,
        endColor: Colors.green.shade600,
        description: 'Code de réception',
      ),
      quick_actions_widget.QuickActionItem(
        id: 'agents',
        label: 'Agents',
        icon: Icons.location_on,
        startColor: Colors.purple.shade500,
        endColor: Colors.purple.shade600,
        description: 'Retrait d\'espèces',
      ),
      quick_actions_widget.QuickActionItem(
        id: 'beneficiaires',
        label: 'Bénéficiaires',
        icon: Icons.people,
        startColor: Colors.orange.shade500,
        endColor: Colors.orange.shade600,
        description: 'Contacts fréquents',
      ),
    ];

    // Initialisation des agents à proximité
    _nearbyAgents = [
      nearby_agents_widget.AgentItem(
        id: 1,
        name: 'Boutique Fatou',
        distance: '0.2 km',
        rating: 4.8,
        available: true,
      ),
      nearby_agents_widget.AgentItem(
        id: 2,
        name: 'Shop Moustapha',
        distance: '0.5 km',
        rating: 4.6,
        available: true,
      ),
      nearby_agents_widget.AgentItem(
        id: 3,
        name: 'Point Service Aminata',
        distance: '0.8 km',
        rating: 4.9,
        available: false,
      ),
    ];

    // Initialisation des taux de change
    _exchangeRates = [
      exchange_rates_widget.CurrencyRate(
        code: 'USD',
        flag: '🇺🇸',
        rate: 1.0876,
        change: 0.12,
      ),
      exchange_rates_widget.CurrencyRate(
        code: 'GBP',
        flag: '🇬🇧',
        rate: 0.8654,
        change: -0.08,
      ),
      exchange_rates_widget.CurrencyRate(
        code: 'CAD',
        flag: '🇨🇦',
        rate: 1.4532,
        change: 0.05,
      ),
    ];

    // Initialisation des transactions récentes
    _recentTransactions = [
      recent_transactions_widget.TransactionItem(
        id: 1,
        type: 'sent',
        amount: '-€250.00',
        recipient: 'Marie Dubois',
        country: 'France',
        status: 'completed',
        paymentMethod: 'Wave',
        date: '2025-01-20',
      ),
      recent_transactions_widget.TransactionItem(
        id: 2,
        type: 'received',
        amount: '+\$450.00',
        sender: 'John Smith',
        country: 'États-Unis',
        status: 'completed',
        paymentMethod: 'Orange Money',
        date: '2025-01-19',
      ),
      recent_transactions_widget.TransactionItem(
        id: 3,
        type: 'sent',
        amount: '-£180.00',
        recipient: 'Sarah Johnson',
        country: 'Royaume-Uni',
        status: 'pending',
        paymentMethod: 'Bank Transfer',
        date: '2025-01-19',
      ),
    ];
  }

  void _handleTabChange(String tab) {
    setState(() {
      _currentTab = tab;
    });
    
    // Navigation vers l'écran correspondant
    switch (tab) {
      case 'profile':
        context.go('/profile');
        break;
      case 'home':
        // Déjà sur l'écran d'accueil
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
  
  void _handleQuickAction(String actionId) {
    // Logique de navigation pour les actions rapides
    switch (actionId) {
      case 'send':
        // Naviguer vers l'écran d'envoi d'argent
        break;
      case 'receive':
        // Naviguer vers l'écran de réception d'argent
        break;
      case 'agents':
        // Naviguer vers l'écran des agents
        break;
      case 'beneficiaires':
        // Naviguer vers l'écran des bénéficiaires
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    // Mettre à jour les notifications en fonction du statut KYC de l'utilisateur
    if (user != null) {
      _notifications[0] = notification_widget.NotificationItem(
        id: 1,
        type: 'KYC',
        message: user.kycStatus == 'PENDING'
            ? 'Vérification KYC en cours - Délai 24-48h'
            : 'Vérification KYC requise pour augmenter vos limites',
        urgent: user.kycStatus == 'NOT_STARTED',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyTransfer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Afficher les notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notifications importantes
                notification_widget.NotificationsSection(notifications: _notifications),
                
                const SizedBox(height: 16),
                
                // Carte avec solde et informations utilisateur
                HeaderBalanceCard(user: user),
                
                const SizedBox(height: 24),
                
                // Actions rapides
                quick_actions_widget.QuickActionsGrid(
                  actions: _quickActions,
                  onActionTap: _handleQuickAction,
                ),
                
                const SizedBox(height: 24),
                
                // Agents à proximité
                nearby_agents_widget.NearbyAgentsCard(
                  agents: _nearbyAgents,
                  onViewAll: () {
                    // Naviguer vers la liste complète des agents
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Taux de change
                exchange_rates_widget.ExchangeRatesCard(rates: _exchangeRates),
                
                const SizedBox(height: 24),
                
                // Transactions récentes
                recent_transactions_widget.RecentTransactionsCard(
                  transactions: _recentTransactions,
                  onViewAll: () {
                    // Naviguer vers l'historique des transactions
                  },
                ),
                
                // Espace supplémentaire en bas pour éviter que le contenu soit caché par la barre de navigation
                const SizedBox(height: 80),
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

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
