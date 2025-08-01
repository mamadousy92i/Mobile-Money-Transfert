// lib/screens/transfer/international_details_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/country_model.dart';
import '../../models/fee_request_model.dart';
import '../../models/fee_response_model.dart';
import '../../models/international_send_request_model.dart';
import '../../models/payment_service_model.dart';
import '../../providers/international_provider.dart';
import '../../providers/transaction_provider.dart';

class InternationalDetailsScreen extends StatefulWidget {
  final Country selectedCountry;

  const InternationalDetailsScreen({super.key, required this.selectedCountry});

  @override
  State<InternationalDetailsScreen> createState() =>
      _InternationalDetailsScreenState();
}

class _InternationalDetailsScreenState extends State<InternationalDetailsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  PaymentService? _selectedService;
  Timer? _debounce;
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeInAnimation;
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

    _fadeInAnimation = Tween<double>(
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _slideController.forward();

    final countryCode = widget.selectedCountry.code;
    if (countryCode != null) {
      Future.microtask(() =>
          Provider.of<InternationalProvider>(context, listen: false)
              .fetchServicesForCountry(countryCode));
    } else {
      debugPrint("ERREUR: Le code du pays est manquant, impossible de charger les services.");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phoneController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final provider = Provider.of<InternationalProvider>(context, listen: false);
    if (provider.feeResponse != null) {
      HapticFeedback.mediumImpact();
      _showConfirmationDialog(provider.feeResponse!);
    } else {
      HapticFeedback.lightImpact();
      _triggerFeeCalculation();
      _showCustomSnackBar(
        'Calcul des frais en cours...',
        primaryEmerald,
        Icons.calculate_rounded,
        showProgress: true,
      );
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon, {bool showProgress = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showProgress) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: cardWhite, size: 16),
              ),
            ],
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showConfirmationDialog(FeeResponse fee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: _isLargeScreen(context) ? 500 : double.infinity,
          ),
          padding: EdgeInsets.all(_getResponsivePadding(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryEmerald.withOpacity(0.05), cardWhite],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec icône
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryEmerald.withOpacity(0.2), lightEmerald.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: primaryEmerald,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Résumé du Transfert',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 22),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Détails du transfert
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryEmerald.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Montant envoyé',
                      '${fee.montantEnvoye} ${fee.deviseOrigine}',
                      false,
                    ),
                    const Divider(height: 24, color: Colors.grey),
                    _buildSummaryRow(
                      'Frais de transfert',
                      '${fee.fraisTotal} ${fee.deviseOrigine}',
                      false,
                    ),
                    const Divider(height: 24, color: Colors.grey),
                    _buildSummaryRow(
                      'Montant reçu',
                      '${fee.montantRecu.toStringAsFixed(2)} ${fee.deviseDestination}',
                      true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryEmerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 18, color: primaryEmerald),
                          const SizedBox(width: 8),
                          Text(
                            'Temps estimé : ${fee.tempsEstime}',
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
              ),
              const SizedBox(height: 28),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          backgroundColor: cardWhite,
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: textGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryEmerald.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          Navigator.of(dialogContext).pop();

                          final prefix = widget.selectedCountry.prefixeTel ?? '';
                          final request = InternationalSendRequest(
                            beneficiaryPhone: '$prefix${_phoneController.text.trim()}',
                            amount: double.parse(_amountController.text.trim()),
                            destinationCountryCode: widget.selectedCountry.code!,
                            destinationServiceCode: _selectedService!.code,
                            localPaymentChannelId: 'f3ed992f-2fd3-4723-8fd3-8cceabba7440',
                          );

                          final internationalProvider = Provider.of<InternationalProvider>(context, listen: false);
                          final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

                          final success = await internationalProvider.sendMoneyInternational(request, transactionProvider);

                          if (mounted) {
                            if (success) {
                              HapticFeedback.lightImpact();
                              _showCustomSnackBar(
                                'Transfert initié avec succès !',
                                Colors.green.shade600,
                                Icons.check_circle_rounded,
                              );
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            } else {
                              HapticFeedback.heavyImpact();
                              _showCustomSnackBar(
                                'Échec de l\'envoi du transfert',
                                Colors.red.shade600,
                                Icons.error_rounded,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryEmerald,
                          foregroundColor: cardWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirmer',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool highlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 14),
            color: textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: highlight ? primaryEmerald : textDark,
          ),
        ),
      ],
    );
  }

  void _triggerFeeCalculation() async {
    if (_amountController.text.isEmpty || _selectedService == null) {
      return;
    }

    final request = FeeRequest(
      montant: double.parse(_amountController.text.trim()),
      corridor: 'SEN_TO_${widget.selectedCountry.code!}',
      serviceDestination: _selectedService!.code,
    );

    await Provider.of<InternationalProvider>(context, listen: false)
        .calculateFees(request);
  }

  @override
  Widget build(BuildContext context) {
    String phoneLabel = 'Numéro du destinataire';
    if (_selectedService?.numeroLongueur != null) {
      phoneLabel = 'Numéro (${_selectedService!.numeroLongueur} chiffres)';
    }

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar moderne avec gradient émeraude
            SliverAppBar(
              expandedHeight: _isLargeScreen(context) ? 140 : 120,
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
                            opacity: _fadeInAnimation,
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
                                  child: Text(
                                    widget.selectedCountry.flag ?? '🌍',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vers ${widget.selectedCountry.nom ?? 'Pays inconnu'}',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 18),
                                          fontWeight: FontWeight.bold,
                                          color: cardWhite,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Transfert international',
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

            // Contenu principal
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: _isLargeScreen(context) ? 800 : double.infinity,
                    ),
                    margin: _isLargeScreen(context)
                        ? EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - 800) / 2)
                        : EdgeInsets.zero,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Section des informations du destinataire
                          SlideTransition(
                            position: _slideAnimation,
                            child: _buildSection(
                              title: 'Informations du destinataire',
                              icon: Icons.person_outline_rounded,
                              child: Column(
                                children: [
                                  _buildModernTextField(
                                    controller: _phoneController,
                                    labelText: phoneLabel,
                                    prefixText: '${widget.selectedCountry.prefixeTel ?? ''} ',
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      if (_selectedService?.numeroLongueur != null)
                                        LengthLimitingTextInputFormatter(_selectedService!.numeroLongueur),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Champ requis';
                                      }
                                      if (_selectedService?.numeroLongueur != null &&
                                          value.length != _selectedService!.numeroLongueur) {
                                        return 'Le numéro doit avoir exactement ${_selectedService!.numeroLongueur} chiffres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildModernTextField(
                                    controller: _amountController,
                                    labelText: 'Montant à envoyer',
                                    suffixText: 'XOF',
                                    prefixIcon: Icons.payments_outlined,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validator: (value) => (value?.isEmpty ?? true) ? 'Champ requis' : null,
                                    onChanged: (value) {
                                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                                      _debounce = Timer(const Duration(milliseconds: 700), () {
                                        if (_formKey.currentState!.validate() && _selectedService != null) {
                                          _triggerFeeCalculation();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section du résumé des frais
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                            )),
                            child: Consumer<InternationalProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading) {
                                  return _buildLoadingCard();
                                }
                                if (provider.feeResponse != null) {
                                  return _buildFeeCard(provider.feeResponse!);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section des services
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                            )),
                            child: _buildSection(
                              title: 'Service de réception',
                              icon: Icons.business_outlined,
                              child: Consumer<InternationalProvider>(
                                builder: (context, provider, child) {
                                  if (provider.isLoading) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(primaryEmerald),
                                        ),
                                      ),
                                    );
                                  }
                                  if (provider.services.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.business_rounded,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Aucun service disponible pour ce pays.',
                                            style: TextStyle(
                                              color: textGrey,
                                              fontSize: _getResponsiveFontSize(context, 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: provider.services.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final service = entry.value;
                                      final isSelected = _selectedService?.code == service.code;
                                      return TweenAnimationBuilder<double>(
                                        duration: Duration(milliseconds: 200 + (index * 100)),
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        builder: (context, value, child) {
                                          return Transform.translate(
                                            offset: Offset(0, 10 * (1 - value)),
                                            child: Opacity(
                                              opacity: value,
                                              child: _buildServiceCard(service, isSelected),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: _isLargeScreen(context) ? 120 : 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          _getResponsivePadding(context),
          16,
          _getResponsivePadding(context),
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Consumer<InternationalProvider>(
            builder: (context, provider, child) {
              final feeResponse = provider.feeResponse;
              final bool canContinue = feeResponse != null &&
                  feeResponse.montantRecu >= 1 &&
                  _selectedService != null;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: canContinue
                      ? [
                    BoxShadow(
                      color: primaryEmerald.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: canContinue ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canContinue ? primaryEmerald : Colors.grey.shade300,
                    foregroundColor: cardWhite,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: EdgeInsets.symmetric(
                      vertical: _isSmallScreen(context) ? 16 : 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (canContinue) ...[
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        'CONTINUER',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              _getResponsivePadding(context),
              _getResponsivePadding(context),
              _getResponsivePadding(context),
              16,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primaryEmerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              _getResponsivePadding(context),
              0,
              _getResponsivePadding(context),
              _getResponsivePadding(context),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    String? prefixText,
    String? suffixText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 16),
          color: textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: textGrey,
            fontSize: _getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w500,
          ),
          prefixText: prefixText,
          prefixStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            color: textDark,
            fontWeight: FontWeight.w600,
          ),
          suffixText: suffixText,
          suffixStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 14),
            color: primaryEmerald,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(prefixIcon, color: primaryEmerald, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryEmerald, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: cardWhite,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: _isSmallScreen(context) ? 16 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context)),
      padding: const EdgeInsets.all(24),
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(primaryEmerald),
          ),
          const SizedBox(width: 16),
          Text(
            'Calcul des frais en cours...',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(FeeResponse fee) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context)),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryEmerald.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                  Icons.calculate_outlined,
                  color: primaryEmerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Résumé des frais',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeeRow(
                  'Frais de transfert',
                  '${fee.fraisTotal} ${fee.deviseOrigine}',
                  false,
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                _buildFeeRow(
                  'Montant reçu',
                  '${fee.montantRecu.toStringAsFixed(2)} ${fee.deviseDestination}',
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, bool highlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 14),
            color: textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: highlight ? primaryEmerald : textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(PaymentService service, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? primaryEmerald.withOpacity(0.1) : backgroundGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryEmerald : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ]
            : [
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
            HapticFeedback.selectionClick();
            setState(() {
              _selectedService = service;
            });
            debugPrint('Service sélectionné: ${service.nom}, Longueur Numéro: ${service.numeroLongueur}');
          },
          child: Padding(
            padding: EdgeInsets.all(_isSmallScreen(context) ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [primaryEmerald.withOpacity(0.2), lightEmerald.withOpacity(0.1)],
                    )
                        : LinearGradient(
                      colors: [Colors.grey.shade200, Colors.grey.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.send_to_mobile_rounded,
                    color: isSelected ? primaryEmerald : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.nom,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveFontSize(context, 16),
                          color: isSelected ? primaryEmerald : textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.type,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                          color: isSelected ? primaryEmerald.withOpacity(0.8) : textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: primaryEmerald,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
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
}