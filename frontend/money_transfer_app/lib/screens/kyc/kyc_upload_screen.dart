// lib/screens/kyc/kyc_upload_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/kyc_provider.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  String _selectedDocumentType = 'CNI'; // Valeur par défaut pour le dropdown

  // Trois variables de type XFile pour stocker les images sélectionnées
  XFile? _frontImageFile;
  XFile? _backImageFile;
  XFile? _selfieImageFile;

  final ImagePicker _picker = ImagePicker();

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

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _documentNumberController.dispose();
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

  /// Ouvre la galerie pour permettre à l'utilisateur de choisir une image.
  Future<XFile?> _pickImage() async {
    HapticFeedback.lightImpact();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return pickedFile;
  }

  /// Gère la soumission du formulaire et l'envoi des documents.
  void _submit() async {
    // On vérifie d'abord que les images obligatoires ont bien été sélectionnées.
    if (_frontImageFile == null || _selfieImageFile == null) {
      HapticFeedback.heavyImpact();
      _showCustomSnackBar(
        'Veuillez fournir au moins le recto et le selfie.',
        Colors.red[500]!,
        Icons.error_outline,
      );
      return;
    }

    // Si le type de document est CNI, le verso est aussi obligatoire.
    if (_selectedDocumentType == 'CNI' && _backImageFile == null) {
      HapticFeedback.heavyImpact();
      _showCustomSnackBar(
        'Pour une CNI, le verso est obligatoire.',
        Colors.orange[600]!,
        Icons.warning_amber_rounded,
      );
      return;
    }

    // On valide les champs de texte (numéro de document).
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      final provider = Provider.of<KycProvider>(context, listen: false);

      // On lit les données binaires ("octets") de chaque image.
      final frontBytes = await _frontImageFile!.readAsBytes();
      final selfieBytes = await _selfieImageFile!.readAsBytes();
      // Le verso est optionnel, donc on utilise un opérateur "null-aware".
      final backBytes = await _backImageFile?.readAsBytes();

      // On appelle le provider pour envoyer les données au backend.
      final success = await provider.submitKycDocument(
        documentType: _selectedDocumentType,
        documentNumber: _documentNumberController.text,
        frontImageBytes: frontBytes,
        frontImageName: _frontImageFile!.name,
        selfieImageBytes: selfieBytes,
        selfieImageName: _selfieImageFile!.name,
        backImageBytes: backBytes,
        backImageName: _backImageFile?.name,
      );

      // On affiche un message de succès ou d'erreur.
      if (mounted) {
        if (success) {
          HapticFeedback.lightImpact();
          _showCustomSnackBar(
            'Documents soumis avec succès !',
            primaryEmerald,
            Icons.check_circle_outline,
          );
          Navigator.of(context).pop(); // On revient à l'écran de profil.
        } else {
          HapticFeedback.heavyImpact();
          _showCustomSnackBar(
            provider.errorMessage ?? 'Une erreur est survenue.',
            Colors.red[500]!,
            Icons.error_outline,
          );
        }
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
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
              child: Icon(icon, color: cardWhite, size: 18),
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
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kycProvider = context.watch<KycProvider>();
    final isLargeScreen = _isLargeScreen(context);
    final responsivePadding = _getResponsivePadding(context);

    // On détermine si le verso est requis en fonction du type de document sélectionné.
    bool isBackImageRequired = _selectedDocumentType == 'CNI';

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
                              Icons.verified_user_rounded,
                              color: cardWhite,
                              size: isLargeScreen ? 36 : 32,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            'Vérification d\'identité',
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
                            'Sécurisez votre compte en quelques étapes',
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
              offset: Offset(0, -20),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 600 : double.infinity,
                ),
                margin: isLargeScreen
                    ? EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - 600) / 2)
                    : EdgeInsets.symmetric(horizontal: responsivePadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Carte d'information
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildInfoCard(),
                      ),
                      SizedBox(height: 24),

                      // Carte de formulaire
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                        )),
                        child: _buildFormCard(isBackImageRequired),
                      ),
                      SizedBox(height: 24),

                      // Carte de téléchargement d'images
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                        )),
                        child: _buildImageUploadCard(isBackImageRequired),
                      ),
                      SizedBox(height: 32),

                      // Bouton de soumission
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.6),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                        )),
                        child: _buildSubmitButton(kycProvider),
                      ),
                      SizedBox(height: 40),
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

  Widget _buildInfoCard() {
    return Container(
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
        children: [
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
                  Icons.info_outline_rounded,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Pourquoi vérifier votre identité ?',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoItem(
            Icons.security_rounded,
            'Sécurité renforcée',
            'Protection contre la fraude et les usurpations d\'identité',
          ),
          SizedBox(height: 16),
          _buildInfoItem(
            Icons.trending_up_rounded,
            'Limites augmentées',
            'Débloquez des montants de transfert plus élevés',
          ),
          SizedBox(height: 16),
          _buildInfoItem(
            Icons.verified_rounded,
            'Compte vérifié',
            'Badge de confiance et accès aux fonctionnalités premium',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryEmerald.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryEmerald, size: 18),
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
                  color: textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 12),
                  color: textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isBackImageRequired) {
    return Container(
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
                  Icons.description_rounded,
                  color: primaryEmerald,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Informations du document',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Dropdown pour le type de document
          Container(
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
            child: DropdownButtonFormField<String>(
              value: _selectedDocumentType,
              items: const [
                DropdownMenuItem(value: 'CNI', child: Text("Carte Nationale d'Identité")),
                DropdownMenuItem(value: 'PASSPORT', child: Text('Passeport')),
              ],
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDocumentType = value);
                }
              },
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                color: textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Type de document',
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
                    Icons.card_membership_rounded,
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: _isSmallScreen(context) ? 16 : 18,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Champ pour le numéro du document
          Container(
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
              controller: _documentNumberController,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                color: textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Numéro du document',
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
                    Icons.numbers_rounded,
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
                  vertical: _isSmallScreen(context) ? 16 : 18,
                ),
              ),
              validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard(bool isBackImageRequired) {
    return Container(
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
                  Icons.photo_camera_rounded,
                  color: Colors.purple[600],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Documents à télécharger',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Image recto
          _buildModernImagePicker(
            title: 'Pièce d\'identité (Recto)',
            subtitle: 'Photo claire et lisible du devant de votre document',
            file: _frontImageFile,
            color: primaryEmerald,
            icon: Icons.credit_card_rounded,
            onTap: () async {
              final image = await _pickImage();
              if (image != null) setState(() => _frontImageFile = image);
            },
          ),
          SizedBox(height: 20),

          // Image verso (conditionnelle)
          if (isBackImageRequired) ...[
            _buildModernImagePicker(
              title: 'Pièce d\'identité (Verso)',
              subtitle: 'Photo claire et lisible du dos de votre document',
              file: _backImageFile,
              color: Colors.blue[600]!,
              icon: Icons.flip_to_back_rounded,
              onTap: () async {
                final image = await _pickImage();
                if (image != null) setState(() => _backImageFile = image);
              },
            ),
            SizedBox(height: 20),
          ],

          // Selfie
          _buildModernImagePicker(
            title: 'Selfie avec document',
            subtitle: 'Selfie de vous tenant votre pièce d\'identité près de votre visage',
            file: _selfieImageFile,
            color: Colors.orange[600]!,
            icon: Icons.face_rounded,
            onTap: () async {
              final image = await _pickImage();
              if (image != null) setState(() => _selfieImageFile = image);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernImagePicker({
    required String title,
    required String subtitle,
    required XFile? file,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _getResponsiveFontSize(context, 16),
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: _getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Zone de téléchargement
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Container(
                height: _isLargeScreen(context) ? 180 : 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: file != null ? color.withOpacity(0.3) : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: file != null ? color.withOpacity(0.02) : backgroundGrey,
                ),
                child: file != null
                    ? Stack(
                  children: [
                    // Image affichée
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: kIsWeb
                          ? Image.network(
                        file.path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                          : Image.file(
                        File(file.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Overlay avec bouton de modification
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardWhite.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: color,
                          size: 16,
                        ),
                      ),
                    ),
                    // Badge de succès
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryEmerald,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryEmerald.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: cardWhite,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Image ajoutée',
                              style: TextStyle(
                                color: cardWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: color,
                        size: _isLargeScreen(context) ? 36 : 32,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Appuyer pour choisir une image',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: _getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'JPG, PNG ou JPEG',
                      style: TextStyle(
                        color: textLight,
                        fontSize: _getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w500,
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

  Widget _buildSubmitButton(KycProvider kycProvider) {
    final isLoading = kycProvider.isLoading;
    final canSubmit = _frontImageFile != null &&
        _selfieImageFile != null &&
        (_selectedDocumentType != 'CNI' || _backImageFile != null);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: canSubmit && !isLoading
                ? primaryEmerald.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: canSubmit && !isLoading ? _submit : null,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              vertical: _isLargeScreen(context) ? 20 : 18,
              horizontal: 24,
            ),
            decoration: BoxDecoration(
              gradient: canSubmit && !isLoading
                  ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primaryEmerald, lightEmerald],
              )
                  : LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[300]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(cardWhite),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cardWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: cardWhite,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Text(
                  isLoading
                      ? 'Vérification en cours...'
                      : 'Soumettre pour vérification',
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