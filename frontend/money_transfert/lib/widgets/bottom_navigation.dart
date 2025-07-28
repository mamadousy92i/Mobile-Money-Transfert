import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final String currentTab;
  final Function(String) onTabChange;

  const BottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'home', 'icon': Icons.home, 'label': 'Accueil'},
      {'id': 'transfer', 'icon': Icons.swap_vert, 'label': 'Transférer'},
      {'id': 'agents', 'icon': Icons.location_on, 'label': 'Agents'},
      {'id': 'history', 'icon': Icons.history, 'label': 'Historique'},
      {'id': 'profile', 'icon': Icons.person, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs.map((tab) {
            final isActive = currentTab == tab['id'];
            
            return Expanded(
              child: InkWell(
                onTap: () => onTabChange(tab['id'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 24,
                        color: isActive 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
