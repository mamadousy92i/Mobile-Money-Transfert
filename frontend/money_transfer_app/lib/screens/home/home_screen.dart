import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';

class MoneyTransferHomePage extends StatefulWidget {
  @override
  _MoneyTransferHomePageState createState() => _MoneyTransferHomePageState();
}

class _MoneyTransferHomePageState extends State<MoneyTransferHomePage>
    with TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _floatingController;

  // Palette de couleurs premium émeraude
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
    _floatingController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    Future.microtask(
          () => Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions(),
    );
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).fetchUnreadCount();

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _refreshHomePage() async {
    HapticFeedback.lightImpact();
    await Future.wait([
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions(),
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ).fetchUserProfile(forceRefresh: true),
      Provider.of<NotificationProvider>(context, listen: false).fetchUnreadCount(),
    ]);
  }

  // Fonctions utilitaires pour la responsivité
  bool _isSmallScreen(BuildContext context) => MediaQuery.of(context).size.width < 360;
  bool _isMediumScreen(BuildContext context) => MediaQuery.of(context).size.width < 768;
  bool _isLargeScreen(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  double _getResponsivePadding(BuildContext context) {
    if (_isLargeScreen(context)) return 32;
    if (_isMediumScreen(context)) return 24;
    return 20;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    if (_isLargeScreen(context)) return baseSize * 1.2;
    if (_isSmallScreen(context)) return baseSize * 0.9;
    return baseSize;
  }

  int _getCrossAxisCount(BuildContext context) {
    if (_isLargeScreen(context)) return 4;
    if (_isMediumScreen(context)) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = _isSmallScreen(context);
    final responsivePadding = _getResponsivePadding(context);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: RefreshIndicator(
        color: primaryEmerald,
        backgroundColor: cardWhite,
        strokeWidth: 3,
        displacement: 60,
        onRefresh: _refreshHomePage,
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            // Header avec effet glassmorphism - responsive
            SliverAppBar(
              expandedHeight: _isLargeScreen(context) ? 280 : _isMediumScreen(context) ? 240 : 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryEmerald.withOpacity(0.8),
                        lightEmerald.withOpacity(0.6),
                        emeraldAccent.withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsivePadding,
                          vertical: _isLargeScreen(context) ? 32 : 20,
                        ),
                        child: _buildPremiumHeader(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Contenu principal avec espacement parfait - responsive
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, _isLargeScreen(context) ? -40 : -30),
                child: Column(
                  children: [
                    // Actions principales flottantes - responsive
                    _buildFloatingActions(context),
                    SizedBox(height: _isLargeScreen(context) ? 48 : 40),

                    // Contenu avec padding responsive
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsivePadding),
                      child: Column(
                        children: [
                          _buildInsightsSection(context),
                          SizedBox(height: _isLargeScreen(context) ? 40 : 32),
                          _buildTransactionHistory(context),
                          SizedBox(height: _isLargeScreen(context) ? 120 : 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    final isLargeScreen = _isLargeScreen(context);

    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  final displayName = auth.userProfile?.fullName ?? 'Utilisateur';
                  final firstName = displayName.split(' ').first;

                  return Expanded(
                    child: Row(
                      children: [
                        // Avatar premium avec animation - responsive
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pushNamed(context, '/profile');
                            },
                            child: Container(
                              width: isLargeScreen ? 68 : isSmallScreen ? 52 : 56,
                              height: isLargeScreen ? 68 : isSmallScreen ? 52 : 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [cardWhite, cardWhite.withOpacity(0.9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: isLargeScreen ? 25 : 20,
                                    offset: Offset(0, isLargeScreen ? 12 : 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 20),
                                    fontWeight: FontWeight.bold,
                                    color: primaryEmerald,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isLargeScreen ? 20 : 16),
                        // Texte de bienvenue élégant - responsive
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  color: cardWhite.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                firstName,
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 28),
                                  fontWeight: FontWeight.bold,
                                  color: cardWhite,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 16),
              // Bouton notifications glassmorphism - responsive
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                    border: Border.all(
                      color: cardWhite.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: isLargeScreen ? 25 : 20,
                        offset: Offset(0, isLargeScreen ? 12 : 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/notifications');
                      },
                      child: Container(
                        padding: EdgeInsets.all(isLargeScreen ? 18 : 14),
                        child: Consumer<NotificationProvider>(
                          builder: (context, notifProvider, child) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  color: cardWhite,
                                  size: isLargeScreen ? 28 : 24,
                                ),
                                if (notifProvider.unreadCount > 0)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: AnimatedBuilder(
                                      animation: _floatingController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: 1.0 + (_floatingController.value * 0.1),
                                          child: Container(
                                            padding: EdgeInsets.all(isLargeScreen ? 6 : 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.red[400]!, Colors.red[600]!],
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: cardWhite, width: 2),
                                            ),
                                            child: Text(
                                              notifProvider.unreadCount > 9 ? '9+' : notifProvider.unreadCount.toString(),
                                              style: TextStyle(
                                                color: cardWhite,
                                                fontSize: isLargeScreen ? 12 : 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _isLargeScreen(context) ? 32 : 24),
          // Slogan élégant - responsive
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic)),
            child: Text(
              'Transférez en toute simplicité',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                color: cardWhite.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    final responsivePadding = _getResponsivePadding(context);

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsivePadding),
        constraints: BoxConstraints(
          maxWidth: _isLargeScreen(context) ? 800 : double.infinity,
        ),
        child: Column(
          children: [
            // Action principale - Envoyer (hero action) - responsive
            _buildHeroAction(context),
            SizedBox(height: _isLargeScreen(context) ? 20 : 16),
            // Actions secondaires - responsive layout
            _isLargeScreen(context)
                ? Row(
              children: [
                Expanded(child: _buildSecondaryAction(
                  context: context,
                  icon: Icons.call_received_rounded,
                  title: 'Recevoir',
                  subtitle: 'Demander un paiement',
                  color: Color(0xFF8B5CF6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/receptions');
                  },
                )),
                SizedBox(width: 20),
                Expanded(child: _buildSecondaryAction(
                  context: context,
                  icon: Icons.location_on_rounded,
                  title: 'Agents',
                  subtitle: 'Points de retrait',
                  color: Color(0xFFEF4444),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/find-agent');
                  },
                )),
                SizedBox(width: 20),
                Expanded(child: _buildSecondaryAction(
                  context: context,
                  icon: Icons.history_rounded,
                  title: 'Historique',
                  subtitle: 'Voir les transactions',
                  color: Color(0xFF3B82F6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/history');
                  },
                )),
                SizedBox(width: 20),
                Expanded(child: _buildSecondaryAction(
                  context: context,
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  subtitle: 'Aide & contact',
                  color: Color(0xFF10B981),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Navigator.pushNamed(context, '/support');
                  },
                )),
              ],
            )
                : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSecondaryAction(
                      context: context,
                      icon: Icons.call_received_rounded,
                      title: 'Recevoir',
                      subtitle: 'Demander',
                      color: Color(0xFF8B5CF6),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/receptions');
                      },
                    )),
                    SizedBox(width: 16),
                    Expanded(child: _buildSecondaryAction(
                      context: context,
                      icon: Icons.location_on_rounded,
                      title: 'Agents',
                      subtitle: 'Localiser',
                      color: Color(0xFFEF4444),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/find-agent');
                      },
                    )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAction(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      width: double.infinity,
      height: isLargeScreen ? 100 : isSmallScreen ? 80 : 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryEmerald, lightEmerald],
        ),
        borderRadius: BorderRadius.circular(isLargeScreen ? 28 : 24),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.4),
            blurRadius: isLargeScreen ? 35 : 30,
            offset: Offset(0, isLargeScreen ? 18 : 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isLargeScreen ? 28 : 24),
          onTap: () {
            HapticFeedback.mediumImpact();
            _showElegantTransferOptions(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 32 : 24,
              vertical: isLargeScreen ? 24 : 20,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  decoration: BoxDecoration(
                    color: cardWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                    border: Border.all(
                      color: cardWhite.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: cardWhite,
                    size: _getResponsiveFontSize(context, 28),
                  ),
                ),
                SizedBox(width: isLargeScreen ? 24 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Envoyer de l\'argent',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: cardWhite,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'National • International',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 13),
                          color: cardWhite.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                  decoration: BoxDecoration(
                    color: cardWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: cardWhite,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = _isSmallScreen(context);
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      height: isLargeScreen ? 140 : isSmallScreen ? 120 : 130,
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: isLargeScreen ? 30 : 25,
            offset: Offset(0, isLargeScreen ? 12 : 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(isLargeScreen ? 18 : 14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: _getResponsiveFontSize(context, 26),
                  ),
                ),
                Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8,
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: isLargeScreen ? 800 : double.infinity,
      ),
      padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(isLargeScreen ? 28 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isLargeScreen ? 25 : 20,
            offset: Offset(0, isLargeScreen ? 10 : 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos transferts',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 4),
                Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                    final totalTransactions = provider.transactions.length;
                    return Text(
                      '$totalTransactions transaction${totalTransactions > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 15),
                        color: textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: primaryEmerald,
              size: isLargeScreen ? 28 : 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showElegantTransferOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: _isLargeScreen(context) ? 600 : double.infinity,
          ),
          margin: _isLargeScreen(context)
              ? EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - 600) / 2)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(_isLargeScreen(context) ? 36 : 32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: _isLargeScreen(context) ? 40 : 32),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context)),
                  child: Text(
                    'Choisir le type de transfert',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ),
                SizedBox(height: _isLargeScreen(context) ? 40 : 32),
                _buildElegantTransferOption(
                  context: context,
                  icon: Icons.public_rounded,
                  title: 'Transfert International',
                  subtitle: 'Vers l\'étranger • Taux compétitifs',
                  color: primaryEmerald,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/international-transfer');
                  },
                ),
                SizedBox(height: 16),
                _buildElegantTransferOption(
                  context: context,
                  icon: Icons.flag_circle_rounded,
                  title: 'Transfert National',
                  subtitle: 'Dans le pays • Instantané',
                  color: lightEmerald,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/send-money');
                  },
                ),
                SizedBox(height: _isLargeScreen(context) ? 40 : 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildElegantTransferOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final responsivePadding = _getResponsivePadding(context);
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsivePadding),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: isLargeScreen ? 25 : 20,
            offset: Offset(0, isLargeScreen ? 10 : 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 28 : 24),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                  ),
                  child: Icon(icon, color: color, size: isLargeScreen ? 32 : 28),
                ),
                SizedBox(width: isLargeScreen ? 24 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                          color: textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: isLargeScreen ? 800 : double.infinity,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activité récente',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primaryEmerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/history');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 20 : 16,
                          vertical: isLargeScreen ? 12 : 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Voir tout',
                              style: TextStyle(
                                color: primaryEmerald,
                                fontWeight: FontWeight.bold,
                                fontSize: _getResponsiveFontSize(context, 16),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: primaryEmerald,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 20),
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return _buildLoadingState(context);
              }

              if (provider.errorMessage != null) {
                return _buildErrorState(context);
              }

              if (provider.transactions.isEmpty) {
                return _buildEmptyState(context);
              }

              // Layout adaptatif pour les transactions
              return isLargeScreen
                  ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                ),
                itemCount: provider.transactions.length > 6 ? 6 : provider.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = provider.transactions[index];
                  return _buildElegantTransactionItem(context, transaction);
                },
              )
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.transactions.length > 5 ? 5 : provider.transactions.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = provider.transactions[index];
                  return _buildElegantTransactionItem(context, transaction);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 56 : 48),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(isLargeScreen ? 28 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isLargeScreen ? 25 : 20,
            offset: Offset(0, isLargeScreen ? 10 : 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: isLargeScreen ? 48 : 40,
            height: isLargeScreen ? 48 : 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryEmerald),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement...',
            style: TextStyle(
              color: textGrey,
              fontWeight: FontWeight.w500,
              fontSize: _getResponsiveFontSize(context, 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 40 : 32),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(isLargeScreen ? 28 : 24),
        border: Border.all(color: Colors.red[100]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: isLargeScreen ? 25 : 20,
            offset: Offset(0, isLargeScreen ? 10 : 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red[500],
              size: isLargeScreen ? 36 : 32,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Impossible de charger les transactions',
            style: TextStyle(
              color: textGrey,
              fontWeight: FontWeight.w500,
              fontSize: _getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 56 : 48),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(isLargeScreen ? 28 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isLargeScreen ? 25 : 20,
            offset: Offset(0, isLargeScreen ? 10 : 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: isLargeScreen ? 48 : 40,
              color: primaryEmerald,
            ),
          ),
          SizedBox(height: isLargeScreen ? 28 : 24),
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
            'Vos transactions apparaîtront ici une fois\nque vous aurez effectué votre premier transfert',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              color: textGrey,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantTransactionItem(BuildContext context, Transaction transaction) {
    final isSent = transaction.typeDisplay == 'Envoi';
    final transactionColor = isSent ? Colors.red[500]! : primaryEmerald;
    final backgroundColor = isSent ? Colors.red[50]! : primaryEmerald.withOpacity(0.05);
    final isLargeScreen = _isLargeScreen(context);
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
        border: Border.all(
          color: transactionColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: transactionColor.withOpacity(0.08),
            blurRadius: isLargeScreen ? 30 : 25,
            offset: Offset(0, isLargeScreen ? 15 : 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
          onTap: () {
            HapticFeedback.lightImpact();
            // Naviguer vers les détails de la transaction
          },
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar de transaction avec animation
                    Container(
                      width: isLargeScreen ? 64 : isSmallScreen ? 52 : 58,
                      height: isLargeScreen ? 64 : isSmallScreen ? 52 : 58,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 18),
                        border: Border.all(
                          color: transactionColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: transactionColor,
                          size: isLargeScreen ? 32 : isSmallScreen ? 24 : 28,
                        ),
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 20 : 16),
                    // Informations de transaction
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSent ? transaction.destinataireNom : transaction.expediteurNom,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          // Montant et date pour desktop/tablette
                          if (isLargeScreen) ...[
                            Text(
                              '${isSent ? "-" : "+"} ${transaction.montantRecu.toStringAsFixed(0)} XOF',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 18),
                                fontWeight: FontWeight.bold,
                                color: transactionColor,
                              ),
                            ),
                            SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryEmerald.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'International',
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 12 : 11,
                                    color: primaryEmerald,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(transaction.statusDisplay).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  transaction.statusDisplay,
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 12 : 11,
                                    color: _getStatusColor(transaction.statusDisplay),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Montant et date pour mobile uniquement
                    if (!isLargeScreen) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isSent ? "-" : "+"} ${transaction.montantRecu.toStringAsFixed(0)} XOF',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: transactionColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatTransactionDate(transaction.createdAt),
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 13),
                              color: textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                // Date pour desktop/tablette
                if (isLargeScreen) ...[
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTransactionDate(transaction.createdAt),
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 13),
                          color: textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: textLight,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'terminé':
      case 'success':
        return primaryEmerald;
      case 'pending':
      case 'en cours':
      case 'processing':
        return Colors.orange[600]!;
      case 'failed':
      case 'échec':
      case 'cancelled':
        return Colors.red[500]!;
      default:
        return textGrey;
    }
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}