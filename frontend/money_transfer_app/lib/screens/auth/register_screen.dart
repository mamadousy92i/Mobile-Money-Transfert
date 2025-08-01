import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _isLoading = false;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  late AnimationController _animationController;
  late AnimationController _floatingController;
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _pageController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fonctions utilitaires pour la responsivité
  bool _isSmallScreen(BuildContext context) => MediaQuery.of(context).size.height < 700;
  bool _isMediumScreen(BuildContext context) => MediaQuery.of(context).size.height < 800;
  bool _isLargeScreen(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    if (_isSmallScreen(context)) return baseSize * 0.85;
    if (_isLargeScreen(context)) return baseSize * 1.1;
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = _isSmallScreen(context);
    final isMediumScreen = _isMediumScreen(context);
    final isLargeScreen = _isLargeScreen(context);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      // Background gradient - ANTI-OVERFLOW avec calcul précis
                      Container(
                        height: isSmallScreen
                            ? constraints.maxHeight * 0.22
                            : isMediumScreen
                            ? constraints.maxHeight * 0.25
                            : constraints.maxHeight * 0.28,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryEmerald, lightEmerald, emeraldAccent],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                      ),

                      // Bouton retour modernisé
                      Positioned(
                        top: 15,
                        left: 20,
                        child: Container(
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
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: cardWhite,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Éléments décoratifs flottants - avec animation
                      if (!isSmallScreen) ...[
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Positioned(
                              top: 35 + (_floatingController.value * 8),
                              right: 25,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: cardWhite.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Positioned(
                              top: 65 - (_floatingController.value * 6),
                              left: 40,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: cardWhite.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // Contenu principal - CENTRÉ pour éviter overflow
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isLargeScreen ? 500 : double.infinity,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width < 360 ? 16 : 24,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Espacement du haut - CALCULÉ pour éviter overflow
                              SizedBox(height: isSmallScreen ? 25 : 35),

                              // Header section - TAILLES RÉDUITES
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Column(
                                    children: [
                                      // Logo container - taille réduite
                                      Container(
                                        width: isSmallScreen ? 65 : 75,
                                        height: isSmallScreen ? 65 : 75,
                                        decoration: BoxDecoration(
                                          color: cardWhite,
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryEmerald.withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.person_add_rounded,
                                          size: isSmallScreen ? 30 : 36,
                                          color: primaryEmerald,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 8 : 12),

                                      Text(
                                        'Créer un compte',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 24),
                                          fontWeight: FontWeight.bold,
                                          color: cardWhite,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Rejoignez MoneyTransfer',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 14),
                                          color: cardWhite.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Espacement - RÉDUIT pour éviter overflow
                              SizedBox(height: isSmallScreen ? 20 : 25),

                              // Indicateur de progression moderne
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      for (int i = 0; i < 2; i++) ...[
                                        Expanded(
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              gradient: i <= _currentStep
                                                  ? LinearGradient(colors: [primaryEmerald, lightEmerald])
                                                  : null,
                                              color: i <= _currentStep ? null : Colors.grey[300],
                                              borderRadius: BorderRadius.circular(3),
                                              boxShadow: i <= _currentStep ? [
                                                BoxShadow(
                                                  color: primaryEmerald.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ] : null,
                                            ),
                                          ),
                                        ),
                                        if (i < 1) const SizedBox(width: 8),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 18 : 25),

                              // Container du formulaire - HAUTEUR CONTRÔLÉE
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: size.width < 360 ? 8 : 0,
                                  ),
                                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                                  decoration: BoxDecoration(
                                    color: cardWhite,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryEmerald.withOpacity(0.1),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: SizedBox(
                                      height: isSmallScreen ? 320 : 380, // HAUTEUR RÉDUITE
                                      child: PageView(
                                        controller: _pageController,
                                        physics: const NeverScrollableScrollPhysics(),
                                        onPageChanged: (index) {
                                          setState(() {
                                            _currentStep = index;
                                          });
                                        },
                                        children: [
                                          _buildPersonalInfoStep(context),
                                          _buildAccountInfoStep(context),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Boutons de navigation - HAUTEUR CONTRÔLÉE
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: size.width < 360 ? 8 : 0,
                                  ),
                                  child: Row(
                                    children: [
                                      // Bouton précédent
                                      if (_currentStep > 0) ...[
                                        Expanded(
                                          child: _buildSecondaryButton('Retour', _previousStep),
                                        ),
                                        const SizedBox(width: 12),
                                      ],

                                      // Bouton suivant/inscription
                                      Expanded(
                                        child: _buildPrimaryButton(
                                          _currentStep == 0 ? 'Continuer' : 'S\'inscrire',
                                          _currentStep == 0 ? _nextStep : _handleRegister,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 12 : 16),

                              // Message d'erreur - COMPACT
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Consumer<AuthProvider>(
                                  builder: (context, authProvider, child) {
                                    if (authProvider.errorMessage != null) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: size.width < 360 ? 8 : 0,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.red[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline_rounded,
                                              color: Colors.red[600],
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                authProvider.errorMessage!,
                                                style: TextStyle(
                                                  color: Colors.red[700],
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: _getResponsiveFontSize(context, 13),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 12 : 16),

                              // Lien vers connexion - COMPACT
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Déjà un compte ? ',
                                      style: TextStyle(
                                        color: textGrey,
                                        fontSize: _getResponsiveFontSize(context, 14),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Se connecter',
                                        style: TextStyle(
                                          color: primaryEmerald,
                                          fontSize: _getResponsiveFontSize(context, 14),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Padding final - MINIMAL pour éviter overflow
                              SizedBox(height: isSmallScreen ? 16 : 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informations personnelles',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Étape 1 sur 2',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 13),
            color: textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Prénom
        _buildModernTextField(
          controller: _firstNameController,
          label: 'Prénom',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Prénom requis';
            }
            return null;
          },
        ),
        SizedBox(height: isSmallScreen ? 14 : 16),

        // Nom
        _buildModernTextField(
          controller: _lastNameController,
          label: 'Nom de famille',
          icon: Icons.badge_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Nom requis';
            }
            return null;
          },
        ),
        SizedBox(height: isSmallScreen ? 14 : 16),

        // Email
        _buildModernTextField(
          controller: _emailController,
          label: 'Adresse email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Email requis';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountInfoStep(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informations de compte',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Étape 2 sur 2',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 13),
            color: textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Téléphone
        _buildModernTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Numéro requis';
            }
            return null;
          },
        ),
        SizedBox(height: isSmallScreen ? 14 : 16),

        // Mot de passe
        _buildModernPasswordField(
          controller: _passwordController,
          label: 'Mot de passe',
          icon: Icons.lock_outline_rounded,
          isVisible: _isPasswordVisible,
          onToggle: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
            HapticFeedback.selectionClick();
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Mot de passe requis';
            }
            if (value!.length < 6) {
              return 'Minimum 6 caractères';
            }
            return null;
          },
        ),
        SizedBox(height: isSmallScreen ? 14 : 16),

        // Confirmation mot de passe
        _buildModernPasswordField(
          controller: _passwordConfirmController,
          label: 'Confirmer le mot de passe',
          icon: Icons.verified_user_outlined,
          isVisible: _isPasswordConfirmVisible,
          onToggle: () {
            setState(() {
              _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
            });
            HapticFeedback.selectionClick();
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Confirmation requise';
            }
            if (value != _passwordController.text) {
              return 'Mots de passe différents';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 15),
          color: textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textGrey,
            fontSize: _getResponsiveFontSize(context, 13),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryEmerald,
              size: 18,
            ),
          ),
          filled: true,
          fillColor: cardWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryEmerald, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 14 : 16, // HAUTEUR CONTRÔLÉE
          ),
          errorStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: validator,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 15),
          color: textDark,
          fontWeight: FontWeight.w500,
          letterSpacing: isVisible ? 0 : 1.2,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textGrey,
            fontSize: _getResponsiveFontSize(context, 13),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryEmerald,
              size: 18,
            ),
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(8),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onToggle,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: textGrey,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          filled: true,
          fillColor: cardWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryEmerald, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 14 : 16, // HAUTEUR CONTRÔLÉE
          ),
          errorStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      height: isSmallScreen ? 48 : 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isLoading
              ? [textGrey, textGrey]
              : [primaryEmerald, lightEmerald],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoading
            ? []
            : [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Text(
                  _isLoading ? 'Traitement...' : text,
                  style: TextStyle(
                    color: cardWhite,
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      height: isSmallScreen ? 48 : 52,
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryEmerald,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Container(
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: primaryEmerald,
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validation première étape
      final firstNameValid = _firstNameController.text.trim().isNotEmpty;
      final lastNameValid = _lastNameController.text.trim().isNotEmpty;
      final emailValid = _emailController.text.trim().isNotEmpty &&
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(_emailController.text.trim());              if (!firstNameValid || !lastNameValid || !emailValid) {
        HapticFeedback.heavyImpact();
        Provider.of<AuthProvider>(context, listen: false)
            .setErrorMessage('Veuillez remplir correctement tous les champs.');
        return;
      }

      Provider.of<AuthProvider>(context, listen: false).clearError();
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      Provider.of<AuthProvider>(context, listen: false).clearError();
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();

    if (password != passwordConfirm) {
      HapticFeedback.heavyImpact();
      Provider.of<AuthProvider>(context, listen: false)
          .setErrorMessage('Les mots de passe ne correspondent pas.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final formattedPhone = phone.startsWith('+') ? phone : '+221$phone';
      final user = User(
        phoneNumber: formattedPhone,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      final success = await Provider.of<AuthProvider>(context, listen: false).register(user);

      if (success) {
        HapticFeedback.lightImpact();
        // Succès géré par AuthProvider
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      // Erreur gérée par AuthProvider
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}