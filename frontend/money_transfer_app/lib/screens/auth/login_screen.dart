import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/login_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

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
      duration: const Duration(milliseconds: 1200),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
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
    _phoneController.dispose();
    _passwordController.dispose();
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
                            ? constraints.maxHeight * 0.32
                            : isMediumScreen
                            ? constraints.maxHeight * 0.35
                            : constraints.maxHeight * 0.38,
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

                      // Éléments décoratifs flottants - avec animation
                      if (!isSmallScreen) ...[
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Positioned(
                              top: 50 + (_floatingController.value * 10),
                              right: 15,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: cardWhite.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(35),
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Positioned(
                              top: 80 - (_floatingController.value * 8),
                              left: 25,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: cardWhite.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
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
                              SizedBox(height: isSmallScreen ? 30 : 50),

                              // Logo et titre - TAILLES RÉDUITES
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Column(
                                    children: [
                                      // Logo container - taille réduite
                                      Container(
                                        width: isSmallScreen ? 70 : 85,
                                        height: isSmallScreen ? 70 : 85,
                                        decoration: BoxDecoration(
                                          color: cardWhite,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryEmerald.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: isSmallScreen ? 35 : 42,
                                          color: primaryEmerald,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 12 : 16),

                                      Text(
                                        'MoneyTransfer',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 28),
                                          fontWeight: FontWeight.bold,
                                          color: cardWhite,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Transferts sécurisés et rapides',
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
                              SizedBox(height: isSmallScreen ? 25 : 35),

                              // Formulaire de connexion - COMPACT
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: size.width < 360 ? 8 : 0,
                                  ),
                                  padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Titre du formulaire - COMPACT
                                        Text(
                                          'Connexion',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(context, 24),
                                            fontWeight: FontWeight.bold,
                                            color: textDark,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Accédez à votre compte',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(context, 14),
                                            color: textGrey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 20 : 28),

                                        // Champ téléphone - HAUTEUR OPTIMISÉE
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
                                        SizedBox(height: isSmallScreen ? 16 : 20),

                                        // Champ mot de passe - HAUTEUR OPTIMISÉE
                                        _buildModernPasswordField(),
                                        SizedBox(height: 8),

                                        // Mot de passe oublié - COMPACT
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              // Navigate to forgot password
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              'Mot de passe oublié ?',
                                              style: TextStyle(
                                                color: primaryEmerald,
                                                fontSize: _getResponsiveFontSize(context, 13),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 16 : 24),

                                        // Bouton de connexion - HAUTEUR FIXE
                                        _buildModernLoginButton(),
                                        SizedBox(height: 16),

                                        // Message d'erreur - COMPACT
                                        Consumer<AuthProvider>(
                                          builder: (context, authProvider, child) {
                                            if (authProvider.errorMessage != null) {
                                              return Container(
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Espacement - MINIMAL
                              SizedBox(height: isSmallScreen ? 16 : 24),

                              // Section inscription - COMPACT
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Nouveau ici ? ',
                                      style: TextStyle(
                                        color: textGrey,
                                        fontSize: _getResponsiveFontSize(context, 14),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.pushNamed(context, '/register');
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
                                        'Créer un compte',
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

                              // Info sécurité - CONDITIONNEL et COMPACT
                              if (!isSmallScreen || size.height > 650) ...[
                                SizedBox(height: 20),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: size.width < 360 ? 8 : 0,
                                    ),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: emeraldAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: emeraldAccent.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.security_rounded,
                                          color: primaryEmerald,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Données protégées par cryptage bancaire',
                                            style: TextStyle(
                                              color: textGrey,
                                              fontSize: _getResponsiveFontSize(context, 11),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              // Padding final - MINIMAL pour éviter overflow
                              SizedBox(height: isSmallScreen ? 16 : 24),
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
          fontSize: _getResponsiveFontSize(context, 16),
          color: textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textGrey,
            fontSize: _getResponsiveFontSize(context, 14),
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
              size: 20,
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
            vertical: isSmallScreen ? 16 : 18, // HAUTEUR CONTRÔLÉE
          ),
          errorStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernPasswordField() {
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
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Mot de passe requis';
          }
          return null;
        },
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 16),
          color: textDark,
          fontWeight: FontWeight.w500,
          letterSpacing: _isPasswordVisible ? 0 : 1.5,
        ),
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          labelStyle: TextStyle(
            color: textGrey,
            fontSize: _getResponsiveFontSize(context, 14),
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
              Icons.lock_outline_rounded,
              color: primaryEmerald,
              size: 20,
            ),
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(8),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: textGrey,
                    size: 20,
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
            vertical: isSmallScreen ? 16 : 18, // HAUTEUR CONTRÔLÉE
          ),
          errorStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoginButton() {
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      width: double.infinity,
      height: isSmallScreen ? 50 : 54, // HAUTEUR FIXE pour éviter overflow
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
            _handleLogin();
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Text(
                  _isLoading ? 'Connexion...' : 'Se connecter',
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

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final user = LoginUser(phoneNumber: phone, password: password);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(user);

      if (success) {
        HapticFeedback.lightImpact();
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}