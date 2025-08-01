// lib/screens/withdraw/withdrawal_code_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/withdrawal_response_model.dart';
import '../../models/reception_model.dart';

class WithdrawalCodeScreen extends StatefulWidget {
  final WithdrawalResponse withdrawal;
  final Reception? reception;

  const WithdrawalCodeScreen({
    super.key,
    required this.withdrawal,
    this.reception,
  });

  @override
  State<WithdrawalCodeScreen> createState() => _WithdrawalCodeScreenState();
}

class _WithdrawalCodeScreenState extends State<WithdrawalCodeScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _showQrCode = true;

  // Palette de couleurs émeraude cohérente
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color lightEmerald = Color(0xFF34D399);
  static const Color darkEmerald = Color(0xFF047857);
  static const Color emeraldAccent = Color(0xFF6EE7B7);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGrey = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF059669);

  // Fonctions pour la responsivité
  bool _isSmallScreen(BuildContext context) => MediaQuery.of(context).size.height < 700;
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
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Démarrer les animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });

    // Animation de pulsation pour le QR code
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _copyCodeToClipboard() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.withdrawal.withdrawalCode));

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
              child: const Icon(
                Icons.check_circle_rounded,
                color: cardWhite,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Code copié dans le presse-papiers',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = _isSmallScreen(context);
    final isTablet = _isLargeScreen(context);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryEmerald, darkEmerald],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Header avec design émeraude
                  _buildResponsiveHeader(isTablet),

                  // Contenu principal
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: isSmallScreen ? 10 : 20),
                      decoration: const BoxDecoration(
                        color: backgroundGrey,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                              _getResponsivePadding(context),
                              isSmallScreen ? 20 : 32,
                              _getResponsivePadding(context),
                              24
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 100,
                              maxWidth: isTablet ? 500 : double.infinity,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Instructions modernisées
                                  _buildInstructionsCard(context),

                                  SizedBox(height: isSmallScreen ? 20 : 32),

                                  // Informations du retrait
                                  if (widget.withdrawal.montantRetire != null)
                                    _buildAmountCard(context),

                                  if (widget.withdrawal.montantRetire != null)
                                    SizedBox(height: isSmallScreen ? 20 : 32),

                                  // Toggle moderne entre QR Code et Code texte
                                  _buildToggleButtons(context),

                                  SizedBox(height: isSmallScreen ? 20 : 32),

                                  // Code de retrait avec animation
                                  _buildCodeContainer(context),

                                  SizedBox(height: isSmallScreen ? 24 : 32),

                                  // Boutons d'action modernisés
                                  _buildActionButtons(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      child: Row(
        children: [
          Container(
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
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: cardWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code de Retrait',
                  style: TextStyle(
                    color: cardWhite,
                    fontSize: _getResponsiveFontSize(context, 22),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Généré avec succès',
                  style: TextStyle(
                    color: cardWhite.withOpacity(0.9),
                    fontSize: _getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Badge de succès avec design émeraude
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cardWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardWhite.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: cardWhite, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Prêt',
                  style: TextStyle(
                    color: cardWhite,
                    fontSize: _getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: primaryEmerald.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: primaryEmerald,
              size: isSmallScreen ? 28 : 32,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Instructions de retrait',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Présentez ce code à ${widget.withdrawal.agentInfo?.nomComplet ?? 'l\'agent'} pour finaliser votre retrait en toute sécurité.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: textGrey,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.green.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [successGreen, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: successGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: cardWhite,
              size: isSmallScreen ? 24 : 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Montant à retirer',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.withdrawal.montantRetire} ${widget.reception?.devise ?? ''}',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Confirmé',
              style: TextStyle(
                color: successGreen,
                fontSize: _getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showQrCode = true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    gradient: _showQrCode
                        ? const LinearGradient(colors: [primaryEmerald, lightEmerald])
                        : null,
                    color: _showQrCode ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_rounded,
                        color: _showQrCode ? cardWhite : textGrey,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'QR Code',
                        style: TextStyle(
                          color: _showQrCode ? cardWhite : textGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showQrCode = false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    gradient: !_showQrCode
                        ? const LinearGradient(colors: [primaryEmerald, lightEmerald])
                        : null,
                    color: !_showQrCode ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.text_fields_rounded,
                        color: !_showQrCode ? cardWhite : textGrey,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Code Texte',
                        style: TextStyle(
                          color: !_showQrCode ? cardWhite : textGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeContainer(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    final isTablet = _isLargeScreen(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isSmallScreen ? 220 : 280,
          maxHeight: isSmallScreen ? 320 : 420,
        ),
        padding: EdgeInsets.all(_getResponsivePadding(context)),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryEmerald.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: primaryEmerald.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: _showQrCode
              ? _buildQrCodeWidget(context)
              : _buildTextCodeWidget(context),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    final buttonHeight = isSmallScreen ? 52.0 : 58.0;

    return Column(
      children: [
        // Bouton copier avec design émeraude
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: _copyCodeToClipboard,
            icon: Icon(
              Icons.copy_rounded,
              size: isSmallScreen ? 20 : 24,
            ),
            label: Text(
              'Copier le code',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryEmerald,
              side: const BorderSide(color: primaryEmerald, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bouton terminé avec gradient émeraude
        Container(
          width: double.infinity,
          height: buttonHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryEmerald, lightEmerald],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryEmerald.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_rounded,
                      color: cardWhite,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'RETOUR À L\'ACCUEIL',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: cardWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeWidget(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    final isTablet = _isLargeScreen(context);
    final qrSize = isSmallScreen ? 160.0 : isTablet ? 240.0 : 200.0;

    return Column(
      key: const ValueKey('qr_code'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Scannez ce QR Code',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        Flexible(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryEmerald.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: primaryEmerald.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    data: widget.withdrawal.withdrawalCode,
                    version: QrVersions.auto,
                    size: qrSize,
                    backgroundColor: cardWhite,
                    foregroundColor: primaryEmerald,
                    gapless: false,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: darkEmerald,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: primaryEmerald,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryEmerald.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.withdrawal.withdrawalCode,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: primaryEmerald,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextCodeWidget(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    final isTablet = _isLargeScreen(context);

    return Column(
      key: const ValueKey('text_code'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Votre code de retrait',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 32),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context),
                vertical: isSmallScreen ? 20 : 24
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryEmerald.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.withdrawal.withdrawalCode,
                style: TextStyle(
                  fontSize: isSmallScreen ? 32 : isTablet ? 48 : 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: isSmallScreen ? 4 : 6,
                  color: primaryEmerald,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security_rounded,
                color: Colors.orange.shade700,
                size: isSmallScreen ? 16 : 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Gardez ce code secret et sécurisé',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: _getResponsiveFontSize(context, 12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}