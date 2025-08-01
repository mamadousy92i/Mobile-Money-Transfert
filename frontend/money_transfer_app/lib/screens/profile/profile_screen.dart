// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Couleurs thème émeraude
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color lightEmerald = Color(0xFF34D399);
  static const Color darkEmerald = Color(0xFF059669);
  static const Color emeraldAccent = Color(0xFF6EE7B7);
  static const Color backgroundGrey = Color(0xFFF9FAFB);
  static const Color cardWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userProfile = authProvider.userProfile;

        return Scaffold(
          backgroundColor: backgroundGrey,
          body: userProfile == null
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryEmerald),
            ),
          )
              : RefreshIndicator(
            color: primaryEmerald,
            onRefresh: () async {
              await Provider.of<AuthProvider>(context, listen: false)
                  .fetchUserProfile();
            },
            child: CustomScrollView(
              slivers: [
                // AppBar moderne avec effet de dégradé
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  backgroundColor: primaryEmerald,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Avatar avec bordure élégante
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: cardWhite,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: emeraldAccent,
                                child: Text(
                                  userProfile.fullName.isNotEmpty
                                      ? userProfile.fullName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: darkEmerald,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Nom utilisateur
                            Text(
                              userProfile.fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: cardWhite,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Email
                            Text(
                              userProfile.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: cardWhite.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Badge de statut KYC
                            _buildStatusBadge(userProfile.kycStatus),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: cardWhite),
                      onPressed: () {
                        Navigator.pushNamed(context, '/edit-profile');
                      },
                    ),
                  ],
                ),

                // Contenu principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Actions rapides
                        _buildQuickActions(context),
                        const SizedBox(height: 24),

                        // Informations personnelles
                        _buildSectionTitle('Informations Personnelles'),
                        const SizedBox(height: 12),
                        _buildModernCard([
                          _buildModernInfoTile(
                            Icons.person_outline,
                            'Nom complet',
                            userProfile.fullName,
                          ),
                          _buildDivider(),
                          _buildModernInfoTile(
                            Icons.email_outlined,
                            'Adresse email',
                            userProfile.email,
                          ),
                          _buildDivider(),
                          _buildModernInfoTile(
                            Icons.phone_outlined,
                            'Téléphone',
                            userProfile.phoneNumber,
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Sécurité et compte
                        _buildSectionTitle('Sécurité & Compte'),
                        const SizedBox(height: 12),
                        _buildModernCard([
                          _buildModernInfoTile(
                            Icons.verified_user_outlined,
                            'Statut de vérification',
                            _getKycStatusText(userProfile.kycStatus),
                            statusColor: _getKycStatusColor(userProfile.kycStatus),
                          ),
                          _buildDivider(),
                          _buildModernInfoTile(
                            Icons.calendar_today_outlined,
                            'Membre depuis',
                            DateFormat('dd MMMM yyyy', 'fr_FR')
                                .format(userProfile.dateJoined),
                          ),
                          _buildDivider(),
                          _buildActionTile(
                            Icons.lock_outline,
                            'Changer le mot de passe',
                            'Modifier vos identifiants de connexion',
                                () => Navigator.pushNamed(context, '/change-password'),
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Carte KYC si nécessaire
                        if (userProfile.kycStatus != 'VERIFIED')
                          _buildKycCard(context, userProfile.kycStatus),

                        const SizedBox(height: 40),

                        // Bouton de déconnexion moderne
                        _buildLogoutButton(context, authProvider),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (status) {
      case 'VERIFIED':
        badgeColor = cardWhite;
        badgeText = 'Vérifié';
        badgeIcon = Icons.verified;
        break;
      case 'PENDING':
        badgeColor = Colors.orange;
        badgeText = 'En attente';
        badgeIcon = Icons.hourglass_top;
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Non vérifié';
        badgeIcon = Icons.shield_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 16,
            color: status == 'VERIFIED' ? primaryEmerald : cardWhite,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status == 'VERIFIED' ? primaryEmerald : cardWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            Icons.edit_outlined,
            'Modifier',
            'Profil',
                () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            Icons.security_outlined,
            'Sécurité',
            'Mot de passe',
                () => Navigator.pushNamed(context, '/change-password'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            Icons.support_agent_outlined,
            'Support',
            'Aide',
                () {
              // Action support
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: emeraldAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryEmerald, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildModernCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernInfoTile(
      IconData icon,
      String title,
      String subtitle, {
        Color? statusColor,
      }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: emeraldAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryEmerald, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: emeraldAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryEmerald, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 56,
    );
  }

  Widget _buildKycCard(BuildContext context, String kycStatus) {
    bool isPending = kycStatus == 'PENDING';

    return GestureDetector(
      onTap: isPending ? null : () {
        // Navigation vers l'écran KYC seulement si ce n'est pas en attente
        Navigator.pushNamed(context, '/kyc-upload');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPending ? Colors.orange.shade50 : emeraldAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending ? Colors.orange.shade200 : emeraldAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPending ? Colors.orange.shade100 : emeraldAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPending ? Icons.hourglass_top : Icons.shield_outlined,
                color: isPending ? Colors.orange.shade700 : primaryEmerald,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPending ? 'Vérification en cours' : 'Vérifiez votre compte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPending ? Colors.orange.shade800 : primaryEmerald,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPending
                        ? 'Vos documents sont en cours de validation.'
                        : 'Complétez votre vérification d\'identité pour débloquer toutes les fonctionnalités.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPending)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          // Dialog de confirmation
          final bool? shouldLogout = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Confirmation'),
                content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: cardWhite,
                    ),
                    child: const Text('Déconnexion'),
                  ),
                ],
              );
            },
          );

          if (shouldLogout == true) {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: cardWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _getKycStatusText(String status) {
    switch (status) {
      case 'VERIFIED':
        return 'Compte vérifié';
      case 'PENDING':
        return 'En cours de vérification';
      default:
        return 'Non vérifié';
    }
  }

  Color _getKycStatusColor(String status) {
    switch (status) {
      case 'VERIFIED':
        return primaryEmerald;
      case 'PENDING':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}