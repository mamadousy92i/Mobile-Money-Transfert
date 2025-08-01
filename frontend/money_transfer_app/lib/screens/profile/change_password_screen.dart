// lib/screens/profile/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;

  bool _isLoading = false;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Fonctions utilitaires pour la responsivité
  bool _isSmallScreen(BuildContext context) => MediaQuery.of(context).size.width < 360;
  bool _isLargeScreen(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  double _getResponsivePadding(BuildContext context) {
    if (_isLargeScreen(context)) return 32;
    return 24;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    if (_isLargeScreen(context)) return baseSize * 1.1;
    if (_isSmallScreen(context)) return baseSize * 0.9;
    return baseSize;
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.lightImpact();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          HapticFeedback.lightImpact();
          _showSuccessSnackbar();
          Navigator.of(context).pop();
        } else {
          HapticFeedback.heavyImpact();
          _showErrorSnackbar(authProvider.errorMessage ?? 'Une erreur est survenue.');
        }
        setState(() => _isLoading = false);
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _showSuccessSnackbar() {
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
                Icons.check_circle_outline,
                color: cardWhite,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Mot de passe changé avec succès !',
                style: TextStyle(
                  color: cardWhite,
                  fontWeight: FontWeight.w600,
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
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
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
                Icons.error_outline,
                color: cardWhite,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: cardWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[500],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = _getResponsivePadding(context);
    final isLargeScreen = _isLargeScreen(context);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // AppBar moderne avec gradient
          SliverAppBar(
            expandedHeight: isLargeScreen ? 220 : 180,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
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
                        FadeTransition(
                          opacity: _fadeController,
                          child: Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: cardWhite.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              color: cardWhite,
                              size: isLargeScreen ? 32 : 28,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: Text(
                            'Changer le mot de passe',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 24),
                              fontWeight: FontWeight.bold,
                              color: cardWhite,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.7),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),

                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenu principal - formulaire centré
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 600 : double.infinity,
                ),
                margin: EdgeInsets.only(
                  left: responsivePadding,
                  right: responsivePadding,
                  top: 30, // Réduit pour éviter l'overflow
                  bottom: 40,
                ),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.all(isLargeScreen ? 36 : 28),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 35,
                          offset: Offset(0, 18),
                        ),
                        BoxShadow(
                          color: primaryEmerald.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de section avec icône
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.security_rounded,
                                color: primaryEmerald,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Sécurité du compte',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 22),
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32), // Espacement généreux après le titre

                        // Ancien mot de passe avec animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(-0.5, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(0.2, 0.7, curve: Curves.easeOutCubic),
                          )),
                          child: _buildModernPasswordField(
                            controller: _oldPasswordController,
                            label: 'Ancien mot de passe',
                            icon: Icons.lock_outline_rounded,
                            isVisible: _isOldPasswordVisible,
                            onToggleVisibility: () {
                              setState(() => _isOldPasswordVisible = !_isOldPasswordVisible);
                              HapticFeedback.selectionClick();
                            },
                            validator: (value) => value!.isEmpty ? 'L\'ancien mot de passe est requis' : null,
                          ),
                        ),
                        SizedBox(height: 28), // Espacement important entre les champs

                        // Nouveau mot de passe avec animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(-0.5, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(0.3, 0.8, curve: Curves.easeOutCubic),
                          )),
                          child: _buildModernPasswordField(
                            controller: _newPasswordController,
                            label: 'Nouveau mot de passe',
                            icon: Icons.lock_reset_rounded,
                            isVisible: _isNewPasswordVisible,
                            onToggleVisibility: () {
                              setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
                              HapticFeedback.selectionClick();
                            },
                            validator: (value) {
                              if (value!.isEmpty) return 'Le nouveau mot de passe est requis';
                              if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 28), // Espacement important entre les champs

                        // Confirmation mot de passe avec animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(-0.5, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(0.4, 0.9, curve: Curves.easeOutCubic),
                          )),
                          child: _buildModernPasswordField(
                            controller: _confirmPasswordController,
                            label: 'Confirmer le nouveau mot de passe',
                            icon: Icons.verified_user_outlined,
                            isVisible: _isConfirmPasswordVisible,
                            onToggleVisibility: () {
                              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                              HapticFeedback.selectionClick();
                            },
                            validator: (value) {
                              if (value!.isEmpty) return 'La confirmation est requise';
                              if (value != _newPasswordController.text) return 'Les mots de passe ne correspondent pas';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 40), // Espacement avant le bouton

                        // Conseil de sécurité
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: emeraldAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: emeraldAccent.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: primaryEmerald,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Utilisez un mot de passe fort avec au moins 8 caractères, incluant des lettres, chiffres et symboles.',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 13),
                                    color: textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32), // Espacement avant le bouton

                        // Bouton de sauvegarde moderne
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                          )),
                          child: _buildModernSaveButton(),
                        ),
                        SizedBox(height: 24), // Espacement final
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: validator,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 16),
          color: textDark,
          fontWeight: FontWeight.w500,
          letterSpacing: isVisible ? 0 : 2,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textGrey,
            fontSize: _getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(14),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryEmerald,
              size: isLargeScreen ? 24 : 22,
            ),
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(8),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onToggleVisibility,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
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
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: primaryEmerald, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 24 : 20,
            vertical: isLargeScreen ? 24 : 20, // Hauteur généreuse pour les champs
          ),
          errorStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernSaveButton() {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      width: double.infinity,
      height: isLargeScreen ? 60 : 56, // Hauteur réduite pour éviter l'overflow
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isLoading
              ? [textLight, textLight]
              : [primaryEmerald, lightEmerald],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isLoading
            ? []
            : [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.4),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isLoading ? null : () {
            HapticFeedback.mediumImpact();
            _handleChangePassword();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                    ),
                  ),
                  SizedBox(width: 18),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cardWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.security_update_good_rounded,
                      color: cardWhite,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    _isLoading ? 'Mise à jour...' : 'Mettre à jour',
                    style: TextStyle(
                      color: cardWhite,
                      fontSize: _getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}