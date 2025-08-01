// lib/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
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
  static const Color textLight = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();

    // Animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // S'assurer que la liste complète est chargée au début
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Fonctions utilitaires pour la responsivité
  bool _isSmallScreen(BuildContext context) => MediaQuery.of(context).size.width < 360;
  bool _isLargeScreen(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  double _getResponsivePadding(BuildContext context) {
    if (_isLargeScreen(context)) return 32;
    return 20;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    if (_isLargeScreen(context)) return baseSize * 1.1;
    if (_isSmallScreen(context)) return baseSize * 0.9;
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;
    final isLargeScreen = _isLargeScreen(context);
    final responsivePadding = _getResponsivePadding(context);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // AppBar moderne avec gradient émeraude
          SliverAppBar(
            expandedHeight: isLargeScreen ? 180 : 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryEmerald,
            leading: Container(
              margin: EdgeInsets.all(8),
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
                  child: Container(
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryEmerald, lightEmerald],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(responsivePadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cardWhite.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              color: cardWhite,
                              size: isLargeScreen ? 36 : 32,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Historique des Transactions',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 24),
                              fontWeight: FontWeight.bold,
                              color: cardWhite,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Suivez toutes vos transactions',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 14),
                              color: cardWhite.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Zone des filtres avec design moderne
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: responsivePadding),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.filter_list_rounded,
                            color: primaryEmerald,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Filtrer par statut',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: [
                        _buildModernFilterChip(
                          'Tous',
                          provider.activeFilter == null,
                          Icons.list_alt_rounded,
                              () {
                            HapticFeedback.lightImpact();
                            provider.fetchTransactions();
                          },
                        ),
                        _buildModernFilterChip(
                          'Terminé',
                          provider.activeFilter == 'TERMINE',
                          Icons.check_circle_outline_rounded,
                              () {
                            HapticFeedback.lightImpact();
                            provider.fetchTransactions(status: 'TERMINE');
                          },
                        ),
                        _buildModernFilterChip(
                          'En cours',
                          provider.activeFilter == 'ENVOYE',
                          Icons.access_time_rounded,
                              () {
                            HapticFeedback.lightImpact();
                            provider.fetchTransactions(status: 'ENVOYE');
                          },
                        ),
                        _buildModernFilterChip(
                          'Annulé',
                          provider.activeFilter == 'ANNULE',
                          Icons.cancel_outlined,
                              () {
                            HapticFeedback.lightImpact();
                            provider.fetchTransactions(status: 'ANNULE');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal
          if (provider.isLoading)
            SliverToBoxAdapter(
              child: Container(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryEmerald),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Chargement des transactions...',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: _getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (transactions.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryEmerald.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.inbox_outlined,
                          size: 60,
                          color: primaryEmerald,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Aucune transaction',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Aucune transaction ne correspond à ce filtre.',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                          color: textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: responsivePadding),
                child: RefreshIndicator(
                  color: primaryEmerald,
                  backgroundColor: cardWhite,
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildModernTransactionItem(context, transaction, index);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(String label, bool isSelected, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected ? [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [primaryEmerald, lightEmerald])
                  : null,
              color: isSelected ? null : cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? cardWhite : textGrey,
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? cardWhite : textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTransactionItem(BuildContext context, Transaction transaction, int index) {
    final isSent = transaction.typeDisplay == 'Envoi';
    final isLargeScreen = _isLargeScreen(context);

    String subtitleText = transaction.canalPaiementNom;
    if (transaction.paysOrigine != null &&
        transaction.paysDestination != null &&
        transaction.paysOrigine != transaction.paysDestination) {
      subtitleText = '${transaction.paysOrigine} → ${transaction.paysDestination}';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(transaction.statusDisplay).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailsScreen(transaction: transaction),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            child: Row(
              children: [
                // Avatar de transaction
                Container(
                  width: isLargeScreen ? 56 : 52,
                  height: isLargeScreen ? 56 : 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSent
                          ? [Colors.red[400]!, Colors.red[500]!]
                          : [primaryEmerald, lightEmerald],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (isSent ? Colors.red[400]! : primaryEmerald).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: cardWhite,
                    size: isLargeScreen ? 26 : 24,
                  ),
                ),
                SizedBox(width: 16),

                // Informations de transaction
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSent ? transaction.destinataireNom : transaction.expediteurNom,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveFontSize(context, 16),
                          color: textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        subtitleText,
                        style: TextStyle(
                          color: textGrey,
                          fontSize: _getResponsiveFontSize(context, 14),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(transaction.statusDisplay).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(transaction.statusDisplay).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              transaction.statusDisplay,
                              style: TextStyle(
                                color: _getStatusColor(transaction.statusDisplay),
                                fontSize: _getResponsiveFontSize(context, 12),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryEmerald.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'International',
                              style: TextStyle(
                                color: primaryEmerald,
                                fontSize: _getResponsiveFontSize(context, 11),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Montant et devise
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isSent ? "-" : "+"} ${transaction.montantRecu.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _getResponsiveFontSize(context, 16),
                        color: isSent ? Colors.red[500] : primaryEmerald,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.deviseReception,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 12),
                        color: textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: textLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERMINE':
      case 'TERMINÉ':
        return primaryEmerald;
      case 'ENVOYE':
      case 'EN COURS':
        return Colors.orange[600]!;
      case 'ANNULE':
      case 'ANNULÉ':
        return Colors.red[500]!;
      default:
        return textGrey;
    }
  }
}