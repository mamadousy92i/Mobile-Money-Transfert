// lib/screens/history/transaction_details_screen.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/transaction_model.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1000),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
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
    final isLargeScreen = _isLargeScreen(context);
    final responsivePadding = _getResponsivePadding(context);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // AppBar moderne avec gradient émeraude
          SliverAppBar(
            expandedHeight: isLargeScreen ? 200 : 180,
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
            actions: [
              Container(
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
                      _copyTransactionCode();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.copy_rounded,
                        color: cardWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                              Icons.receipt_long_rounded,
                              color: cardWhite,
                              size: isLargeScreen ? 36 : 32,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Détails de Transaction',
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
                            widget.transaction.codeTransaction,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 14),
                              color: cardWhite.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
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

          // Contenu principal
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsivePadding),
                child: Column(
                  children: [
                    // Carte de statut principale
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildStatusCard(),
                    ),
                    SizedBox(height: 20),

                    // Carte des détails financiers
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                      )),
                      child: _buildFinancialDetailsCard(),
                    ),
                    SizedBox(height: 20),

                    // Carte des participants
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                      )),
                      child: _buildPartyDetailsCard(),
                    ),
                    SizedBox(height: 20),

                    // Carte timeline/statut
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.6),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                      )),
                      child: _buildTimelineCard(),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isSent = widget.transaction.typeDisplay == 'Envoi';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_isLargeScreen(context) ? 32 : 28),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(widget.transaction.statusTransaction).withOpacity(0.15),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar de transaction
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSent
                      ? [Colors.red[400]!, Colors.red[500]!]
                      : [primaryEmerald, lightEmerald],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isSent ? Colors.red[400]! : primaryEmerald).withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: cardWhite,
                size: _isLargeScreen(context) ? 32 : 28,
              ),
            ),
          ),
          SizedBox(height: 24),

          // Montant principal
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              '${widget.transaction.montantEnvoye.toStringAsFixed(2)} ${widget.transaction.deviseEnvoi}',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 32),
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Badge de statut
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(widget.transaction.statusTransaction).withOpacity(0.1),
                  _getStatusColor(widget.transaction.statusTransaction).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(widget.transaction.statusTransaction).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.transaction.statusTransaction),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  widget.transaction.statusDisplay.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(widget.transaction.statusTransaction),
                    fontSize: _getResponsiveFontSize(context, 14),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  textLight.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Informations de base
          _buildDetailRow('Date de création', DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(widget.transaction.createdAt)),
          _buildDetailRow('Code de transaction', widget.transaction.codeTransaction),
        ],
      ),
    );
  }

  Widget _buildFinancialDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_isLargeScreen(context) ? 28 : 24),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.1),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: primaryEmerald,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Détails Financiers',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Détails financiers
          _buildDetailRow(
            'Montant envoyé',
            '${widget.transaction.montantEnvoye.toStringAsFixed(2)} ${widget.transaction.deviseEnvoi}',
            valueColor: Colors.red[500],
          ),
          _buildDetailRow(
            'Frais de service',
            '${widget.transaction.frais} ${widget.transaction.deviseEnvoi}',
            valueColor: Colors.orange[600],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  textLight.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          _buildDetailRow(
            'Montant reçu',
            '${widget.transaction.montantRecu.toStringAsFixed(2)} ${widget.transaction.deviseReception}',
            valueColor: primaryEmerald,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPartyDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_isLargeScreen(context) ? 28 : 24),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Participants',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Expéditeur
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red[100]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.red[600],
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expéditeur',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 12),
                          color: Colors.red[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.transaction.expediteurNom,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Destinataire
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryEmerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryEmerald.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryEmerald.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: primaryEmerald,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destinataire',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 12),
                          color: primaryEmerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.transaction.destinataireNom,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Parcours si international
          if (widget.transaction.paysOrigine != widget.transaction.paysDestination) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.public_rounded,
                      color: Colors.orange[600],
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parcours International',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 12),
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.transaction.paysOrigine} → ${widget.transaction.paysDestination}',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_isLargeScreen(context) ? 28 : 24),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: Colors.purple[600],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Suivi de Transaction',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Timeline simple
          _buildTimelineItem(
            'Transaction initiée',
            DateFormat('dd/MM/yyyy HH:mm').format(widget.transaction.createdAt),
            Icons.send_rounded,
            true,
          ),
          _buildTimelineItem(
            'En cours de traitement',
            widget.transaction.statusTransaction == 'ENVOYE' ? 'Maintenant' : 'Terminé',
            Icons.hourglass_top_rounded,
            widget.transaction.statusTransaction == 'ENVOYE' || widget.transaction.statusTransaction == 'TERMINE',
          ),
          _buildTimelineItem(
            'Transaction terminée',
            widget.transaction.statusTransaction == 'TERMINE' ? 'Terminé' : 'En attente',
            Icons.check_circle_rounded,
            widget.transaction.statusTransaction == 'TERMINE',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, IconData icon, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted ? primaryEmerald : textLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isCompleted ? cardWhite : textLight,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? textDark : textGrey,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 12),
                    color: textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {Color? valueColor, bool isHighlighted = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: isHighlighted ? BoxDecoration(
        color: primaryEmerald.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ) : null,
      child: Padding(
        padding: isHighlighted ? EdgeInsets.symmetric(horizontal: 12) : EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textGrey,
                fontSize: _getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? textDark,
                  fontSize: _getResponsiveFontSize(context, 14),
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyTransactionCode() {
    Clipboard.setData(ClipboardData(text: widget.transaction.codeTransaction));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cardWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.copy_rounded,
                color: cardWhite,
                size: 16,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Code de transaction copié !',
              style: TextStyle(
                color: cardWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: primaryEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERMINE':
        return primaryEmerald;
      case 'ENVOYE':
        return Colors.orange[600]!;
      case 'ANNULE':
        return Colors.red[500]!;
      default:
        return textGrey;
    }
  }
}