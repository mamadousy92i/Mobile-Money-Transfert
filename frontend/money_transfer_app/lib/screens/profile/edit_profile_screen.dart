// lib/screens/profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _isLoading = false;

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

    // On récupère le profil utilisateur actuel pour pré-remplir les champs
    final UserProfile? userProfile = Provider.of<AuthProvider>(context, listen: false).userProfile;

    _firstNameController = TextEditingController(text: userProfile?.firstName ?? '');
    _lastNameController = TextEditingController(text: userProfile?.lastName ?? '');
    _emailController = TextEditingController(text: userProfile?.email ?? '');

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
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

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.lightImpact();

      final Map<String, dynamic> data = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
      };

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateUserProfile(data);

      if (mounted) {
        if (success) {
          HapticFeedback.lightImpact();
          _showSuccessSnackbar();
          Navigator.of(context).pop(); // Revenir à l'écran de profil
        } else {
          HapticFeedback.heavyImpact();
          _showErrorSnackbar();
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
                'Profil mis à jour avec succès !',
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

  void _showErrorSnackbar() {
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
                'Erreur lors de la mise à jour. Veuillez réessayer.',
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
            expandedHeight: isLargeScreen ? 180 : 140,
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
              centerTitle: false,
              titlePadding: EdgeInsets.only(
                left: responsivePadding,
                bottom: 16,
              ),
              title: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                )),
                child: Text(
                  'Modifier votre profil',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: cardWhite,
                  ),

                ),

              ),
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
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: cardWhite.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: cardWhite,
                              size: isLargeScreen ? 32 : 28,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.7),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: Text(
                            '',
                            textAlign: TextAlign.center,
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

          // Contenu principal
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 600 : double.infinity,
                ),
                margin: isLargeScreen
                    ? EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - 600) / 2)
                    : EdgeInsets.zero,
                child: Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: responsivePadding),
                    padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de section
                        Text(
                          'Informations personnelles',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Champs de formulaire avec animations
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(-0.5, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(0.2, 0.8, curve: Curves.easeOutCubic),
                          )),
                          child: _buildModernTextField(
                            controller: _firstNameController,
                            label: 'Prénom',
                            icon: Icons.person_outline_rounded,
                            validator: (value) => value!.isEmpty ? 'Le prénom ne peut pas être vide' : null,
                          ),
                        ),
                        SizedBox(height: 20),

                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(-0.5, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(0.3, 0.9, curve: Curves.easeOutCubic),
                          )),
                          child: _buildModernTextField(
                            controller: _lastNameController,
                            label: 'Nom de famille',
                            icon: Icons.badge_outlined,
                            validator: (value) => value!.isEmpty ? 'Le nom ne peut pas être vide' : null,
                          ),
                        ),
                        SizedBox(height: 20),

                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(-0.5, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                          )),
                          child: _buildModernTextField(
                            controller: _emailController,
                            label: 'Adresse email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) return 'L\'email ne peut pas être vide';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 40),

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
                        SizedBox(height: 20),
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.05),
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
              size: isLargeScreen ? 22 : 20,
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
            horizontal: isLargeScreen ? 20 : 16,
            vertical: isLargeScreen ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernSaveButton() {
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      width: double.infinity,
      height: isLargeScreen ? 64 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isLoading
              ? [textLight, textLight]
              : [primaryEmerald, lightEmerald],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoading
            ? []
            : [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : () {
            HapticFeedback.mediumImpact();
            _handleSave();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                    ),
                  ),
                  SizedBox(width: 16),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cardWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.save_rounded,
                      color: cardWhite,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Text(
                  _isLoading ? 'Enregistrement...' : 'Enregistrer les modifications',
                  style: TextStyle(
                    color: cardWhite,
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
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