// lib/screens/notifications/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  // État pour gérer le mode de sélection et les IDs des notifications sélectionnées
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

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

    // On charge les notifications au démarrage de l'écran
    Future.microtask(() {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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

  /// Méthode appelée par le RefreshIndicator pour recharger les données.
  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    // On rafraîchit en utilisant le filtre qui est actuellement actif
    await provider.fetchNotifications(status: provider.activeFilter);
  }

  /// Active ou désactive le mode de sélection.
  void _toggleSelectionMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      // Si on quitte le mode sélection, on vide la liste des sélections
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
  }

  /// Ajoute ou retire une notification de la liste des sélections.
  void _onNotificationSelected(int id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  /// Appelle le provider pour supprimer les notifications sélectionnées.
  void _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    HapticFeedback.mediumImpact();
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final success = await provider.deleteNotifications(_selectedIds.toList());

    if (mounted) {
      _showCustomSnackBar(
        success
            ? '${_selectedIds.length} notification(s) supprimée(s)'
            : 'Échec de la suppression',
        success ? primaryEmerald : Colors.red[500]!,
        success ? Icons.check_circle_outline : Icons.error_outline,
      );

      // Si la suppression a réussi, on quitte le mode sélection
      if (success) {
        setState(() {
          _selectedIds.clear();
          _isSelectionMode = false;
        });
      }
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
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    final isLargeScreen = _isLargeScreen(context);
    final responsivePadding = _getResponsivePadding(context);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // AppBar moderne avec gradient émeraude
          SliverAppBar(
            expandedHeight: isLargeScreen ? 180 : 160,
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
            actions: [
              // Bouton de suppression en mode sélection
              if (_isSelectionMode)
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _deleteSelected,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: cardWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              // Bouton mode sélection/annuler
              Container(
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
                    onTap: _toggleSelectionMode,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        _isSelectionMode ? Icons.close_rounded : Icons.checklist_rounded,
                        color: cardWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                              Icons.notifications_rounded,
                              color: cardWhite,
                              size: isLargeScreen ? 36 : 32,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            _isSelectionMode
                                ? '${_selectedIds.length} sélectionnée(s)'
                                : 'Notifications',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 24),
                              fontWeight: FontWeight.bold,
                              color: cardWhite,
                            ),
                          ),
                        ),
                        if (!_isSelectionMode) ...[
                          SizedBox(height: 4),
                          SlideTransition(
                            position: _slideAnimation,
                            child: Text(
                              'Restez informé de toutes vos activités',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 14),
                                color: cardWhite.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Zone des filtres
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: responsivePadding),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: _buildModernFilterChips(provider),
              ),
            ),
          ),

          // Liste des notifications
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: responsivePadding),
              child: RefreshIndicator(
                color: primaryEmerald,
                backgroundColor: cardWhite,
                onRefresh: _handleRefresh,
                child: provider.isLoading && notifications.isEmpty
                    ? Container(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryEmerald),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chargement des notifications...',
                          style: TextStyle(
                            color: textGrey,
                            fontSize: _getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildModernNotificationTile(notification, index);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChips(NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryEmerald.withOpacity(0.1), lightEmerald.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: primaryEmerald,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Filtrer les notifications',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildModernFilterChip(provider, 'Toutes', null)),
            SizedBox(width: 12),
            Expanded(child: _buildModernFilterChip(provider, 'Non lues', 'UNREAD')),
          ],
        ),
      ],
    );
  }

  Widget _buildModernFilterChip(NotificationProvider provider, String label, String? status) {
    final bool isSelected = provider.activeFilter == status;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected ? [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            provider.fetchNotifications(status: status);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [primaryEmerald, lightEmerald])
                  : null,
              color: isSelected ? null : cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? cardWhite : textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(context, 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryEmerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 60,
                color: primaryEmerald,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vous êtes à jour ! Aucune nouvelle notification.',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 14),
                color: textGrey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNotificationTile(NotificationModel notification, int index) {
    final iconInfo = _getIconForType(notification.notificationType);
    final bool isSelected = _selectedIds.contains(notification.id);
    final isLargeScreen = _isLargeScreen(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: primaryEmerald, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryEmerald.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 20 : 15,
            offset: Offset(0, isSelected ? 8 : 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (_isSelectionMode) {
              _onNotificationSelected(notification.id);
            } else {
              _showNotificationDetails(context, notification);
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _onNotificationSelected(notification.id);
            }
          },
          child: Container(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar ou checkbox
                Container(
                  width: 48,
                  height: 48,
                  child: _isSelectionMode
                      ? Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primaryEmerald : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? Icons.check_rounded : null,
                      color: cardWhite,
                      size: 24,
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          iconInfo['color'].withOpacity(0.1),
                          iconInfo['color'].withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      iconInfo['icon'],
                      color: iconInfo['color'],
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Contenu de la notification
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isUnread && !_isSelectionMode
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: _getResponsiveFontSize(context, 16),
                                color: textDark,
                              ),
                            ),
                          ),
                          if (notification.isUnread && !_isSelectionMode)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: primaryEmerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: textGrey,
                          fontSize: _getResponsiveFontSize(context, 14),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: iconInfo['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getTypeLabel(notification.notificationType),
                              style: TextStyle(
                                color: iconInfo['color'],
                                fontSize: _getResponsiveFontSize(context, 11),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              color: textLight,
                              fontSize: _getResponsiveFontSize(context, 12),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Affiche un dialogue avec les détails complets d'une notification.
  void _showNotificationDetails(BuildContext context, NotificationModel notification) {
    if (notification.isUnread) {
      Provider.of<NotificationProvider>(context, listen: false)
          .markNotificationAsRead(notification.id);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final iconInfo = _getIconForType(notification.notificationType);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconInfo['color'].withOpacity(0.1),
                      iconInfo['color'].withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconInfo['icon'],
                  color: iconInfo['color'],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: textLight),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(notification.createdAt),
                        style: TextStyle(
                          color: textLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryEmerald, lightEmerald]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    color: cardWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Retourne une icône et une couleur en fonction du type de notification.
  Map<String, dynamic> _getIconForType(String type) {
    switch (type) {
      case 'TRANSACTION':
        return {'icon': Icons.swap_horiz_rounded, 'color': primaryEmerald};
      case 'ALERT':
        return {'icon': Icons.warning_amber_rounded, 'color': Colors.orange[600]};
      case 'INFO':
        return {'icon': Icons.info_outline_rounded, 'color': Colors.blue[600]};
      default:
        return {'icon': Icons.notifications_rounded, 'color': textGrey};
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'TRANSACTION':
        return 'Transaction';
      case 'ALERT':
        return 'Alerte';
      case 'INFO':
        return 'Information';
      default:
        return 'Notification';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}