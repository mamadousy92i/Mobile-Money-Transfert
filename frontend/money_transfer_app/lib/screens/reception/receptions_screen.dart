// lib/screens/reception/receptions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/reception_model.dart';
import '../../providers/reception_provider.dart';
import '../agent/find_agent_screen.dart';

class ReceptionsScreen extends StatefulWidget {
  const ReceptionsScreen({super.key});

  @override
  State<ReceptionsScreen> createState() => _ReceptionsScreenState();
}

class _ReceptionsScreenState extends State<ReceptionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Couleurs du thème émeraude
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color lightEmerald = Color(0xFF34D399);
  static const Color darkEmerald = Color(0xFF047857);
  static const Color emeraldAccent = Color(0xFF6EE7B7);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGrey = Color(0xFF64748B);

  // Fonctions pour la responsivité
  bool _isSmallScreen(BuildContext context) => MediaQuery.of(context).size.width < 360;
  bool _isLargeScreen(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  double _getResponsivePadding(BuildContext context) {
    if (_isLargeScreen(context)) return 32;
    if (_isSmallScreen(context)) return 16;
    return 24;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    if (_isLargeScreen(context)) return baseSize * 1.1;
    if (_isSmallScreen(context)) return baseSize * 0.9;
    return baseSize;
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _slideController.forward();

    // Par défaut, on charge les réceptions actives
    Future.microtask(() =>
        Provider.of<ReceptionProvider>(context, listen: false).fetchReceptions());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Méthode appelée par le RefreshIndicator pour recharger les données avec le filtre actif.
  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    final provider = Provider.of<ReceptionProvider>(context, listen: false);
    await provider.fetchReceptions(status: provider.activeFilter);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceptionProvider>();
    final receptions = provider.receptions;

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar moderne avec gradient émeraude
            SliverAppBar(
              expandedHeight: _isLargeScreen(context) ? 160 : 140,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: primaryEmerald,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cardWhite.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: cardWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryEmerald, lightEmerald],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(_getResponsivePadding(context)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardWhite.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: cardWhite.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.inbox_rounded,
                                    color: cardWhite,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mes Transferts',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 20),
                                          fontWeight: FontWeight.bold,
                                          color: cardWhite,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'À recevoir',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 14),
                                          color: cardWhite.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Zone des filtres
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildFilterChips(provider),
                ),
              ),
            ),

            // Contenu principal
            SliverToBoxAdapter(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: _isLargeScreen(context) ? 800 : double.infinity,
                ),
                margin: _isLargeScreen(context)
                    ? EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - 800) / 2)
                    : EdgeInsets.zero,
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: primaryEmerald,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 500),
                    child: provider.isLoading && receptions.isEmpty
                        ? _buildLoadingState()
                        : receptions.isEmpty
                        ? _buildEmptyState()
                        : _buildReceptionsList(receptions),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la barre de puces de filtrage.
  Widget _buildFilterChips(ReceptionProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context)),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: primaryEmerald,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Filtrer par statut',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(provider, 'Tous', null),
                _buildFilterChip(provider, 'Actifs', 'ACTIVE'),
                _buildFilterChip(provider, 'Retirés', 'RETIRE'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget d'aide pour construire une seule puce de filtre.
  Widget _buildFilterChip(ReceptionProvider provider, String label, String? status) {
    final bool isSelected = provider.activeFilter == status;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            HapticFeedback.selectionClick();
            provider.fetchReceptions(status: status == 'ALL' ? null : status);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [primaryEmerald, lightEmerald],
              )
                  : null,
              color: isSelected ? null : backgroundGrey,
              borderRadius: BorderRadius.circular(25),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade300),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? cardWhite : textGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: _getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(primaryEmerald),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Chargement des transferts...',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  /// Widget affiché lorsque la liste des réceptions est vide.
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 40,
                    color: Colors.orange.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucun transfert trouvé',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun transfert ne correspond à ce filtre.\nTirez vers le bas pour rafraîchir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                    color: textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryEmerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, color: primaryEmerald, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tirez pour actualiser',
                        style: TextStyle(
                          color: primaryEmerald,
                          fontWeight: FontWeight.w600,
                          fontSize: _getResponsiveFontSize(context, 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildReceptionsList(List<Reception> receptions) {
    return Container(
      margin: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        children: receptions.asMap().entries.map((entry) {
          final index = entry.key;
          final reception = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildReceptionCard(context, reception),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  /// Construit une Card pour afficher les détails d'une réception.
  Widget _buildReceptionCard(BuildContext context, Reception reception) {
    final statusInfo = _getStatusInfo(reception.statutReception);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            _showWithdrawalOptions(context, reception);
          },
          child: Padding(
            padding: EdgeInsets.all(_isSmallScreen(context) ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${NumberFormat.decimalPattern('fr').format(reception.montantAttendu)} ${reception.devise}',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusInfo['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusInfo['color'].withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusInfo['icon'],
                            color: statusInfo['color'],
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusInfo['label'],
                            style: TextStyle(
                              color: statusInfo['color'],
                              fontWeight: FontWeight.bold,
                              fontSize: _getResponsiveFontSize(context, 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade100,
                        Colors.grey.shade200,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryEmerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: primaryEmerald,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'De : ${reception.expediteurNom}',
                        style: TextStyle(
                          color: textDark,
                          fontSize: _getResponsiveFontSize(context, 15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.blue.shade600,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Le ${DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(reception.dateCreation)}',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: _getResponsiveFontSize(context, 13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!['RETIRE', 'ANNULE'].contains(reception.statutReception)) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, color: primaryEmerald, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Appuyez pour retirer',
                          style: TextStyle(
                            color: primaryEmerald,
                            fontWeight: FontWeight.w600,
                            fontSize: _getResponsiveFontSize(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retourne une couleur, une icône et un label en fonction du statut.
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return {
          'color': Colors.orange.shade600,
          'icon': Icons.hourglass_top_rounded,
          'label': 'EN ATTENTE'
        };
      case 'NOTIFIE':
      case 'CONFIRME':
        return {
          'color': primaryEmerald,
          'icon': Icons.notifications_active_rounded,
          'label': 'A RETIRER'
        };
      case 'RETIRE':
        return {
          'color': Colors.green.shade600,
          'icon': Icons.check_circle_rounded,
          'label': 'RETIRE'
        };
      default:
        return {
          'color': Colors.grey.shade600,
          'icon': Icons.info_outline_rounded,
          'label': status
        };
    }
  }

  /// Affiche la modal pour choisir le type de retrait.
  void _showWithdrawalOptions(BuildContext context, Reception reception) {
    final inactiveStatuses = ['RETIRE', 'ANNULE'];
    if (inactiveStatuses.contains(reception.statutReception)) {
      return;
    }

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(_getResponsivePadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryEmerald.withOpacity(0.2), lightEmerald.withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: primaryEmerald,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Options de retrait',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${NumberFormat.decimalPattern('fr').format(reception.montantAttendu)} ${reception.devise}',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 14),
                                    color: primaryEmerald,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Option retrait physique
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FindAgentScreen(reception: reception),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      color: Colors.blue.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Retrait physique',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(context, 16),
                                            fontWeight: FontWeight.bold,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Chez un agent partenaire',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(context, 14),
                                            color: textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: textGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Option Mobile Money
                      Container(
                        decoration: BoxDecoration(
                          color: cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              Navigator.pop(ctx);

                              final provider = Provider.of<ReceptionProvider>(context, listen: false);

                              // Snackbar de traitement avec design moderne
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'Traitement de votre demande...',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(context, 14),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: primaryEmerald,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  elevation: 6,
                                ),
                              );

                              final success = await provider.requestDigitalWithdrawal(reception.id);

                              ScaffoldMessenger.of(context).hideCurrentSnackBar();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: cardWhite.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            success ? Icons.check_circle_rounded : Icons.error_rounded,
                                            color: cardWhite,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            success
                                                ? 'Transfert vers votre compte réussi !'
                                                : 'Échec du retrait digital.',
                                            style: TextStyle(
                                              fontSize: _getResponsiveFontSize(context, 14),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                    elevation: 6,
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primaryEmerald.withOpacity(0.2), lightEmerald.withOpacity(0.1)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.send_to_mobile_rounded,
                                      color: primaryEmerald,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mobile Money',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(context, 16),
                                            fontWeight: FontWeight.bold,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Directement sur votre compte',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(context, 14),
                                            color: textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryEmerald.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Instantané',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(context, 10),
                                        color: primaryEmerald,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}