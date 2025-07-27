import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../models/country.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/country_picker.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPassword = false;
  Country _selectedCountry = Country.countries[0];

  // Contrôleurs pour le formulaire de connexion
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _rememberMe = ValueNotifier<bool>(false);

  // Contrôleurs pour le formulaire d'inscription
  final _registerFirstNameController = TextEditingController();
  final _registerLastNameController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _acceptTerms = ValueNotifier<bool>(false);

  // Clés pour les formulaires
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Variable d'état pour le bouton de connexion
  bool _loginButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Ajouter des écouteurs pour mettre à jour l'état du bouton
    _loginPhoneController.addListener(_updateLoginButtonState);
    _loginPasswordController.addListener(_updateLoginButtonState);
  }

  @override
  void dispose() {
    _tabController.dispose();
    
    // Supprimer les écouteurs avant de disposer les contrôleurs
    _loginPhoneController.removeListener(_updateLoginButtonState);
    _loginPasswordController.removeListener(_updateLoginButtonState);
    
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _registerFirstNameController.dispose();
    _registerLastNameController.dispose();
    _registerPhoneController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _rememberMe.dispose();
    _acceptTerms.dispose();
    super.dispose();
  }

  // Méthode pour mettre à jour l'état du bouton de connexion
  void _updateLoginButtonState() {
    final newState = _loginPhoneController.text.isEmpty || _loginPasswordController.text.isEmpty;
    if (newState != _loginButtonDisabled) {
      setState(() {
        _loginButtonDisabled = newState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Logo et titre
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Carte avec onglets
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Onglets
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Connexion'),
                            Tab(text: 'Inscription'),
                          ],
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorSize: TabBarIndicatorSize.tab,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Contenu des onglets
                        SizedBox(
                          // Utiliser une hauteur qui s'adapte au contenu mais avec une contrainte minimale
                          height: _tabController.index == 0 ? 380 : 600,
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(), // Désactiver le défilement horizontal
                            children: [
                              SingleChildScrollView(child: _buildLoginTab()),
                              SingleChildScrollView(child: _buildRegisterTab()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Avantages
                _buildAdvantages(),
                
                const SizedBox(height: 24),
                
                // Footer
                Text(
                  'En vous connectant, vous acceptez nos conditions d\'utilisation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade100,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smartphone,
                color: Color(0xFF2563EB),
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'MoneyTransfer',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Transferts d\'argent simples et sécurisés',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade100,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Form(
          key: _loginFormKey,
          child: Column(
            children: [
              // Titre
              const Text(
                'Bon retour !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connectez-vous pour continuer',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              
              // Champ téléphone - Approche complètement différente
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Utiliser un TextField personnalisé avec préfixe intégré
                  TextFormField(
                    controller: _loginPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '77 123 45 67',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      // Utiliser un préfixe intégré au TextFormField
                      prefixIcon: GestureDetector(
                        onTap: () {
                          // Afficher le sélecteur de pays
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) => _buildCountryList(),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8, right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCountry.flag,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCountry.code,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Champ mot de passe
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mot de passe',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _loginPasswordController,
                    obscureText: !_showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Votre mot de passe',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Options supplémentaires
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min, // Utiliser la taille minimale nécessaire
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _rememberMe,
                        builder: (context, value, child) {
                          return Checkbox(
                            value: value,
                            onChanged: (newValue) {
                              _rememberMe.value = newValue ?? false;
                            },
                          );
                        },
                      ),
                      const Text(
                        'Se souvenir de moi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Naviguer vers la page de récupération de mot de passe
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Bouton de connexion
              CustomButton(
                text: 'Se connecter',
                icon: Icons.arrow_forward,
                isLoading: authProvider.isLoading,
                isDisabled: false, // Forcer l'activation du bouton
                onPressed: () async {
                  if (_loginFormKey.currentState!.validate()) {
                    final phone = '${_selectedCountry.code}${_loginPhoneController.text.trim()}';
                    final success = await authProvider.login(
                      phone,
                      _loginPasswordController.text,
                    );
                    
                    if (success && context.mounted) {
                      // Naviguer vers la page d'accueil
                      Navigator.pushReplacementNamed(context, '/home');
                    } else if (context.mounted) {
                      // Afficher une erreur
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.error ?? 'Une erreur est survenue'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Form(
          key: _registerFormKey,
          child: Column(
            children: [
              // Titre
              const Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rejoignez des millions d\'utilisateurs',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              
              // Prénom et nom
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Prénom',
                      placeholder: 'Alex',
                      controller: _registerFirstNameController,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Nom',
                      placeholder: 'Honoré',
                      controller: _registerLastNameController,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Numéro de téléphone - Approche complètement différente
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Utiliser un TextField personnalisé avec préfixe intégré
                  TextFormField(
                    controller: _registerPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '77 123 45 67',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      // Utiliser un préfixe intégré au TextFormField
                      prefixIcon: GestureDetector(
                        onTap: () {
                          // Afficher le sélecteur de pays
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) => _buildCountryList(),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8, right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCountry.flag,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCountry.code,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Email
              CustomTextField(
                label: 'Email',
                placeholder: 'alex.honore@example.com',
                controller: _registerEmailController,
                keyboardType: TextInputType.emailAddress,
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Mot de passe
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mot de passe',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _registerPasswordController,
                    obscureText: !_showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 8) {
                        return 'Le mot de passe doit contenir au moins 8 caractères';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Au moins 8 caractères',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Confirmer mot de passe
              CustomTextField(
                label: 'Confirmer le mot de passe',
                placeholder: 'Retapez votre mot de passe',
                controller: _registerConfirmPasswordController,
                obscureText: true,
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  }
                  if (value != _registerPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Conditions d'utilisation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _acceptTerms,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (newValue) {
                          _acceptTerms.value = newValue ?? false;
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          text: 'J\'accepte les ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          children: [
                            TextSpan(
                              text: 'conditions d\'utilisation',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Naviguer vers les conditions d'utilisation
                                },
                            ),
                            const TextSpan(text: ' et la '),
                            TextSpan(
                              text: 'politique de confidentialité',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Naviguer vers la politique de confidentialité
                                },
                            ),
                          ],
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Bouton d'inscription
              ValueListenableBuilder<bool>(
                valueListenable: _acceptTerms,
                builder: (context, acceptTerms, _) {
                  return CustomButton(
                    text: 'Créer mon compte',
                    icon: Icons.arrow_forward,
                    isLoading: authProvider.isLoading,
                    isDisabled: !acceptTerms || 
                      _registerPasswordController.text != _registerConfirmPasswordController.text ||
                      _registerFirstNameController.text.isEmpty ||
                      _registerLastNameController.text.isEmpty ||
                      _registerPhoneController.text.isEmpty ||
                      _registerEmailController.text.isEmpty ||
                      _registerPasswordController.text.isEmpty,
                    backgroundColor: const Color(0xFF10B981),
                    onPressed: () async {
                      if (_registerFormKey.currentState!.validate() && acceptTerms) {
                        final phone = '${_selectedCountry.code}${_registerPhoneController.text.trim()}';
                        final success = await authProvider.register(
                          firstName: _registerFirstNameController.text,
                          lastName: _registerLastNameController.text,
                          phone_number: phone,
                          email: _registerEmailController.text,
                          password: _registerPasswordController.text,
                        );
                        
                        if (success && context.mounted) {
                          // Naviguer vers la page d'accueil
                          Navigator.pushReplacementNamed(context, '/home');
                        } else if (context.mounted) {
                          // Afficher une erreur
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.error ?? 'Une erreur est survenue'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvantages() {
    return Column(
      children: [
        _buildAdvantageItem(
          icon: Icons.shield,
          title: '100% sécurisé',
          description: 'Vos données sont protégées par un cryptage SSL',
        ),
        const SizedBox(height: 16),
        _buildAdvantageItem(
          icon: Icons.language,
          title: 'Transferts internationaux',
          description: 'Envoyez de l\'argent dans plus de 150 pays',
        ),
        const SizedBox(height: 16),
        _buildAdvantageItem(
          icon: Icons.check_circle,
          title: 'Rapide et fiable',
          description: 'Transactions traitées en quelques minutes',
        ),
      ],
    );
  }

  Widget _buildAdvantageItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade100,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Méthode pour construire la liste des pays
  Widget _buildCountryList() {
    final countries = [
      Country(name: 'Sénégal', code: '+221', flag: '🇸🇳'),
      Country(name: 'Mali', code: '+223', flag: '🇲🇱'),
      Country(name: 'Côte d\'Ivoire', code: '+225', flag: '🇨🇮'),
      Country(name: 'Burkina Faso', code: '+226', flag: '🇧🇫'),
      Country(name: 'Togo', code: '+228', flag: '🇹🇬'),
      Country(name: 'Bénin', code: '+229', flag: '🇧🇯'),
      Country(name: 'Niger', code: '+227', flag: '🇳🇪'),
      Country(name: 'Guinée', code: '+224', flag: '🇬🇳'),
      Country(name: 'Cameroun', code: '+237', flag: '🇨🇲'),
      // Ajoutez d'autres pays selon vos besoins
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sélectionnez un pays',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(country.name),
                  subtitle: Text(country.code),
                  onTap: () {
                    setState(() {
                      _selectedCountry = country;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
