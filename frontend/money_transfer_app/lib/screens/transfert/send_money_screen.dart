import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../models/send_money_request_model.dart';
import '../../providers/payment_channel_provider.dart';
import '../../providers/transaction_provider.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _searchController = TextEditingController();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  final int _totalSteps = 3;

  String? _selectedPaymentChannelId;
  String? _selectedPaymentChannelName;
  bool _isLoading = false;
  bool _isPermissionGranted = false;
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  Contact? _selectedContact;
  double _fees = 0.0;

  late AnimationController _animationController;
  late AnimationController _stepController;
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

  // Fonction pour la responsivité
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

  // Corrected: Properly structured switch statement with returns
  Map<String, dynamic> _getChannelStyling(String channelType) {
    switch (channelType) {
      case 'WAVE':
        return {
          'icon': Icons.waves_rounded,
          'color': Colors.blue.shade600,
          'backgroundColor': Colors.blue.shade50,
        };
      case 'ORANGE_MONEY':
        return {
          'icon': Icons.phone_android_rounded,
          'color': Colors.orange.shade600,
          'backgroundColor': Colors.orange.shade50,
        };
      default:
        return {
          'icon': Icons.credit_card_rounded,
          'color': primaryEmerald,
          'backgroundColor': emeraldAccent.withOpacity(0.2),
        };
    }
  }

  // Moved and corrected phone number formatting
  String _formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('221') && cleanPhone.length >= 12) {
      return cleanPhone.substring(3, 12);
    } else if (cleanPhone.startsWith('00221') && cleanPhone.length >= 14) {
      return cleanPhone.substring(5, 14);
    }

    if (cleanPhone.length >= 9) {
      return cleanPhone.substring(cleanPhone.length - 9);
    }

    return cleanPhone;
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts.where((contact) {
          if (contact.phones.isEmpty) return false;
          final name = contact.displayName.toLowerCase();
          final phone = contact.phones.first.number.replaceAll(RegExp(r'[^\d]'), '');
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _stepController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _stepController.forward();

    _loadContacts();
    // Corrected: Removed unnecessary Future.microtask
    Provider.of<PaymentChannelProvider>(context, listen: false).fetchPaymentChannels();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _searchController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  // Corrected: Added user feedback for errors and permission issues
  Future<void> _loadContacts() async {
    if (kIsWeb) {
      setState(() {
        _isPermissionGranted = false;
        _contacts = [];
        _filteredContacts = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Accès aux contacts non disponible sur le web'),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    try {
      PermissionStatus status = await Permission.contacts.status;

      if (status.isDenied) {
        status = await Permission.contacts.request();
      }

      if (status.isGranted) {
        setState(() => _isPermissionGranted = true);
        try {
          final contacts = await FlutterContacts.getContacts(withProperties: true);
          setState(() {
            _contacts = contacts.where((contact) => contact.phones.isNotEmpty).toList();
            _filteredContacts = _contacts;
          });
        } catch (e) {
          debugPrint("Erreur lors du chargement des contacts: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erreur lors du chargement des contacts'),
              backgroundColor: Colors.red.shade500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permission d\'accès aux contacts refusée'),
            backgroundColor: Colors.red.shade500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur de permissions sur cette plateforme: $e");
      setState(() {
        _isPermissionGranted = false;
        _contacts = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de la vérification des permissions'),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Corrected: Handle invalid input and reset fees
  void _calculateFees() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    if (amount > 0) {
      setState(() {
        if (amount <= 5000) {
          _fees = 50;
        } else if (amount <= 25000) {
          _fees = amount * 0.015;
        } else {
          _fees = amount * 0.02;
        }
      });
    } else {
      setState(() => _fees = 0);
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      bool canProceed = false;

      switch (_currentStep) {
        case 0:
          final phoneLength = _phoneController.text.length;
          canProceed = phoneLength >= 7 && phoneLength <= 9;
          break;
        case 1:
          final amount = double.tryParse(_amountController.text) ?? 0;
          canProceed = amount >= 100;
          if (canProceed) _calculateFees();
          break;
        case 2:
          canProceed = _selectedPaymentChannelId != null;
          break;
      }

      if (canProceed) {
        HapticFeedback.lightImpact();
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _animationController.reset();
        _animationController.forward();
        _stepController.reset();
        _stepController.forward();
      } else {
        HapticFeedback.heavyImpact();
        _showValidationError();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showValidationError() {
    String message = '';
    switch (_currentStep) {
      case 0:
        message = 'Veuillez saisir un numéro valide (7 à 9 chiffres)';
        break;
      case 1:
        message = 'Veuillez saisir un montant minimum de 100 FCFA';
        break;
      case 2:
        message = 'Veuillez choisir un service de paiement';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cardWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_outline, color: cardWhite, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Corrected: Added null check for payment channel
  void _handleSendMoney() async {
    if (_selectedPaymentChannelId == null) {
      _showValidationError();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final request = SendMoneyRequest(
      beneficiaryPhone: '+221${_phoneController.text.trim()}',
      amount: double.parse(_amountController.text.trim()),
      paymentChannelId: _selectedPaymentChannelId!,
    );

    final success = await Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).sendMoney(request);

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.lightImpact();
      _showSuccessDialog();
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error_outline, color: cardWhite, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Échec du transfert. Veuillez réessayer.')),
            ],
          ),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: _isLargeScreen(context) ? 400 : double.infinity,
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: primaryEmerald,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: cardWhite, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  'Transfert réussi !',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre argent a été envoyé avec succès.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryEmerald,
                      foregroundColor: cardWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                      // Added: Accessibility support
                      semanticsLabel: 'Continuer après transfert réussi',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipientStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Destinataire',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Saisissez le numéro ou choisissez dans vos contacts',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              color: textGrey,
            ),
          ),
          const SizedBox(height: 32),

          // Champ de saisie du numéro
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (value) {
                if (_selectedContact != null) {
                  setState(() => _selectedContact = null);
                }
              },
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                color: textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '77 123 45 67',
                hintStyle: TextStyle(color: textGrey.withOpacity(0.6)),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone_android_rounded, color: primaryEmerald, size: 24),
                ),
                prefixText: '+221 ',
                prefixStyle: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 18),
                  color: textDark,
                  fontWeight: FontWeight.w500,
                ),
                suffixIcon: _phoneController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: textGrey),
                  onPressed: () {
                    _phoneController.clear();
                    setState(() => _selectedContact = null);
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: cardWhite,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: _isSmallScreen(context) ? 16 : 20,
                ),
                // Added: Accessibility support
                labelText: 'Numéro de téléphone',
                semanticCounterText: 'Numéro de téléphone du destinataire',
              ),
            ),
          ),

          // Séparateur "OU"
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OU',
                  style: TextStyle(
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 24),

          // Section Contacts
          if (kIsWeb)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.web_rounded,
                      size: 48,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Navigation Web',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'L\'accès aux contacts n\'est pas disponible sur navigateur web pour des raisons de sécurité.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 14),
                      color: textGrey,
                    ),
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
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: primaryEmerald,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Conseil : Saisissez directement le numéro ci-dessus',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 12),
                              color: primaryEmerald,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (!_isPermissionGranted)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryEmerald.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.contact_phone_rounded, size: 48, color: primaryEmerald),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Accéder à vos contacts',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Autorisez l\'accès pour sélectionner facilement un destinataire depuis vos contacts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 14),
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadContacts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryEmerald,
                      foregroundColor: cardWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Autoriser l\'accès',
                      semanticsLabel: 'Autoriser l\'accès aux contacts',
                    ),
                  ),
                ],
              ),
            )
          else if (_contacts.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(primaryEmerald),
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundGrey,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.contacts_rounded, color: primaryEmerald, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Vos contacts (${_filteredContacts.length})',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: cardWhite,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _filterContacts,
                              decoration: InputDecoration(
                                hintText: 'Rechercher un contact...',
                                hintStyle: TextStyle(
                                  color: textGrey.withOpacity(0.7),
                                  fontSize: _getResponsiveFontSize(context, 14),
                                ),
                                prefixIcon: Icon(Icons.search_rounded, color: textGrey, size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: textGrey, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterContacts('');
                                  },
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                // Added: Accessibility support
                                labelText: 'Rechercher un contact',
                              ),
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 14),
                                color: textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredContacts.isEmpty
                          ? Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: textGrey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Aucun contact trouvé'
                                  : 'Aucun contact disponible',
                              style: TextStyle(
                                color: textGrey,
                                fontSize: _getResponsiveFontSize(context, 16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Essayez un autre terme de recherche',
                                style: TextStyle(
                                  color: textGrey.withOpacity(0.7),
                                  fontSize: _getResponsiveFontSize(context, 14),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          // Corrected: Check for empty phone numbers
                          if (contact.phones.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final phone = contact.phones.first.number;
                          final displayPhone = _formatPhoneNumber(phone);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _selectedContact == contact
                                  ? primaryEmerald.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: primaryEmerald.withOpacity(0.2),
                                child: Text(
                                  contact.displayName.isNotEmpty
                                      ? contact.displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: primaryEmerald,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                contact.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: _getResponsiveFontSize(context, 15),
                                ),
                              ),
                              subtitle: Text(
                                '+221 $displayPhone',
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: _getResponsiveFontSize(context, 13),
                                ),
                              ),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedContact = contact;
                                  _phoneController.text = displayPhone;
                                });
                              },
                              trailing: _selectedContact == contact
                                  ? Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: primaryEmerald,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: cardWhite,
                                  size: 16,
                                ),
                              )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Montant à envoyer',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Saisissez le montant que vous souhaitez envoyer',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            color: textGrey,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryEmerald.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            onChanged: (value) => _calculateFees(),
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 24),
              color: textDark,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '5000',
              hintStyle: TextStyle(color: textGrey.withOpacity(0.6)),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade100, Colors.green.shade50],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: Colors.green.shade600, size: 24),
              ),
              suffixText: 'FCFA',
              suffixStyle: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                color: textGrey,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: cardWhite,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: _isSmallScreen(context) ? 16 : 20,
              ),
              // Added: Accessibility support
              labelText: 'Montant',
              semanticCounterText: 'Montant à envoyer en FCFA',
            ),
          ),
        ),
        if (_fees > 0) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Montant:',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: _getResponsiveFontSize(context, 14),
                      ),
                    ),
                    Text(
                      '${_amountController.text} FCFA',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _getResponsiveFontSize(context, 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Frais:',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: _getResponsiveFontSize(context, 14),
                      ),
                    ),
                    Text(
                      '${_fees.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _getResponsiveFontSize(context, 14),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    Text(
                      '${(double.tryParse(_amountController.text) ?? 0 + _fees).toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: primaryEmerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Service de paiement',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez votre méthode de paiement',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            color: textGrey,
          ),
        ),
        const SizedBox(height: 32),
        Consumer<PaymentChannelProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(primaryEmerald),
                  ),
                ),
              );
            }

            return Column(
              children: provider.channels.map((channel) {
                final styling = _getChannelStyling(channel.typeCanal);
                final isSelected = _selectedPaymentChannelId == channel.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedPaymentChannelId = channel.id;
                          _selectedPaymentChannelName = channel.canalName;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? styling['color'].withOpacity(0.1) : cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? styling['color'] : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: styling['color'].withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              )
                            else
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: styling['backgroundColor'],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(styling['icon'], color: styling['color'], size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                channel.canalName,
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? styling['color'] : textDark,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: styling['color'],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: cardWhite, size: 16),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsivePadding(context),
        vertical: 16,
      ),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: isCompleted || isActive
                          ? const LinearGradient(
                        colors: [primaryEmerald, lightEmerald],
                      )
                          : null,
                      color: isCompleted || isActive ? null : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < _totalSteps - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(_getResponsivePadding(context)),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryEmerald, lightEmerald],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: cardWhite),
                    // Added: Accessibility support
                    tooltip: 'Retour',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Envoyer de l\'argent',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: cardWhite,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cardWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentStep + 1}/$_totalSteps',
                      style: TextStyle(
                        color: cardWhite,
                        fontSize: _getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildStepIndicator(),

            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: EdgeInsets.all(_getResponsivePadding(context)),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildRecipientStep(),
                        _buildAmountStep(),
                        _buildPaymentMethodStep(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.all(_getResponsivePadding(context)),
              decoration: BoxDecoration(
                color: cardWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
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
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: _isSmallScreen(context) ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: BorderSide(color: Colors.grey.shade300),
                              backgroundColor: cardWhite,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_back_ios_rounded, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Précédent',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 14),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  // Added: Accessibility support
                                  semanticsLabel: 'Retour à l\'étape précédente',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      flex: _currentStep > 0 ? 1 : 1,
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
                          onPressed: _isLoading
                              ? null
                              : (_currentStep == _totalSteps - 1 ? _handleSendMoney : _nextStep),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryEmerald,
                            foregroundColor: cardWhite,
                            padding: EdgeInsets.symmetric(
                              vertical: _isSmallScreen(context) ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_currentStep == _totalSteps - 1) ...[
                                const Icon(Icons.send_rounded, size: 18),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _currentStep == _totalSteps - 1 ? 'ENVOYER' : 'Suivant',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                                // Added: Accessibility support
                                semanticsLabel: _currentStep == _totalSteps - 1
                                    ? 'Envoyer le transfert'
                                    : 'Passer à l\'étape suivante',
                              ),
                              if (_currentStep != _totalSteps - 1) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ],
                            ],
                          ),
                        ),
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
}