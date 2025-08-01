// lib/screens/transfer/international_transfer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/international_provider.dart';
import 'international_details_screen.dart';

class InternationalTransferScreen extends StatefulWidget {
  const InternationalTransferScreen({super.key});

  @override
  State<InternationalTransferScreen> createState() => _InternationalTransferScreenState();
}

class _InternationalTransferScreenState extends State<InternationalTransferScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  String _searchQuery = '';

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

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.elasticOut,
    ));

    // Charger la liste des pays au démarrage
    Future.microtask(() {
      const String userCountryCode = 'SEN';
      Provider.of<InternationalProvider>(context, listen: false)
          .fetchCountries(userCountryCode: userCountryCode);
      _animationController.forward();
      _searchAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    HapticFeedback.selectionClick();
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar moderne avec gradient émeraude
            SliverAppBar(
              expandedHeight: _isLargeScreen(context) ? 160 : 140,
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
                                  child: const Icon(
                                    Icons.public_rounded,
                                    color: cardWhite,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transfert International',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 20),
                                          fontWeight: FontWeight.bold,
                                          color: cardWhite,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Choisissez votre destination',
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
                  child: Consumer<InternationalProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return _buildLoadingState();
                      }

                      if (provider.countries.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Filtrer les pays selon la recherche
                      final filteredCountries = provider.countries.where((country) {
                        final countryName = (country.nom ?? '').toLowerCase();
                        final countryCode = (country.code ?? '').toLowerCase();
                        final devise = (country.devise ?? '').toLowerCase();

                        return countryName.contains(_searchQuery) ||
                            countryCode.contains(_searchQuery) ||
                            devise.contains(_searchQuery);
                      }).toList();

                      return Container(
                        constraints: BoxConstraints(
                          maxWidth: _isLargeScreen(context) ? 800 : double.infinity,
                        ),
                        margin: _isLargeScreen(context)
                            ? EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - 800) / 2)
                            : EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Barre de recherche
                            _buildSearchBar(),

                            // En-tête avec statistiques
                            _buildHeader(provider.countries.length, filteredCountries.length),

                            // Liste des pays
                            Container(
                              constraints: const BoxConstraints(minHeight: 400),
                              child: filteredCountries.isEmpty
                                  ? _buildNoResultsState()
                                  : _buildCountriesList(filteredCountries),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryEmerald),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chargement des pays...',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryEmerald.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.public_off_rounded,
                    size: 40,
                    color: primaryEmerald,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucun pays disponible',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vérifiez votre connexion et réessayez',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Provider.of<InternationalProvider>(context, listen: false)
                          .fetchCountries();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryEmerald,
                      foregroundColor: cardWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(_getResponsivePadding(context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            color: textDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher un pays...',
            hintStyle: TextStyle(
              color: textGrey.withOpacity(0.7),
              fontSize: _getResponsiveFontSize(context, 16),
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
              child: const Icon(
                Icons.search_rounded,
                color: primaryEmerald,
                size: 20,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? Container(
              margin: const EdgeInsets.all(8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.clear_rounded,
                      color: textGrey,
                      size: 16,
                    ),
                  ),
                ),
              ),
            )
                : null,
            filled: true,
            fillColor: cardWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: primaryEmerald, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: _isSmallScreen(context) ? 16 : 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalCountries, int filteredCountries) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context)),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
            child: const Icon(
              Icons.public_rounded,
              color: primaryEmerald,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pays disponibles',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _searchQuery.isEmpty
                      ? '$totalCountries pays au total'
                      : '$filteredCountries résultat${filteredCountries > 1 ? 's' : ''} sur $totalCountries',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 12),
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryEmerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$filteredCountries',
                style: const TextStyle(
                  color: primaryEmerald,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 30,
                    color: Colors.orange.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun résultat trouvé',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Essayez avec d\'autres mots-clés',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                    color: textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCountriesList(List countries) {
    return Container(
      margin: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        children: countries.asMap().entries.map((entry) {
          final index = entry.key;
          final country = entry.value;
          return _buildCountryCard(country, index);
        }).toList(),
      ),
    );
  }

  Widget _buildCountryCard(country, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            InternationalDetailsScreen(selectedCountry: country),
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            )),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(_isSmallScreen(context) ? 16 : 20),
                    child: Row(
                      children: [
                        // Flag container
                        Container(
                          width: _isSmallScreen(context) ? 50 : 56,
                          height: _isSmallScreen(context) ? 50 : 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryEmerald.withOpacity(0.1),
                                lightEmerald.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryEmerald.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              country.flag ?? '🏳️',
                              style: TextStyle(
                                fontSize: _isSmallScreen(context) ? 24 : 28,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: _isSmallScreen(context) ? 12 : 16),

                        // Country info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                country.nom ?? 'Nom inconnu',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryEmerald.withOpacity(0.1),
                                          lightEmerald.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      country.devise ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(context, 11),
                                        fontWeight: FontWeight.bold,
                                        color: primaryEmerald,
                                      ),
                                    ),
                                  ),
                                  if (country.prefixeTel != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        country.prefixeTel!,
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(context, 11),
                                          color: textGrey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Arrow icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryEmerald.withOpacity(0.1),
                                lightEmerald.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: primaryEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}