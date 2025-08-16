import 'package:flutter/material.dart';
import '../../models/user.dart';

class HeaderBalanceCard extends StatefulWidget {
  final User? user;
  
  const HeaderBalanceCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HeaderBalanceCard> createState() => _HeaderBalanceCardState();
}

class _HeaderBalanceCardState extends State<HeaderBalanceCard> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final userStatus = {
      'kycStatus': widget.user?.kycStatus ?? 'NOT_STARTED',
      'verificationLevel': widget.user?.verificationLevel ?? 'Basic',
      'monthlyLimit': widget.user?.kycStatus == 'VERIFIED' ? 5000 : 1000,
      'usedLimit': 450,
      'firstName': widget.user?.firstName ?? 'Utilisateur'
    };

    Widget getKycStatusIcon() {
      IconData iconData;
      Color iconColor;
      Color bgColor;
      String text;

      switch (userStatus['kycStatus']) {
        case 'VERIFIED':
          iconData = Icons.check_circle;
          iconColor = Colors.green.shade600;
          bgColor = Colors.green.shade100;
          text = 'Vérifié';
          break;
        case 'PENDING':
          iconData = Icons.access_time;
          iconColor = Colors.orange.shade600;
          bgColor = Colors.orange.shade100;
          text = 'En cours';
          break;
        case 'REJECTED':
          iconData = Icons.warning_amber;
          iconColor = Colors.red.shade600;
          bgColor = Colors.red.shade100;
          text = 'Rejeté';
          break;
        default:
          iconData = Icons.shield;
          iconColor = Colors.grey.shade600;
          bgColor = Colors.grey.shade100;
          text = 'Non vérifié';
      }

      return Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withBlue(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec salutation et statut KYC
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${userStatus['firstName']}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez vos transactions internationales',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade100,
                    ),
                  ),
                ],
              ),
              getKycStatusIcon(),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Solde principal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solde total',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade100,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _showBalance ? '€2,847.50' : '••••••',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _showBalance ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showBalance = !_showBalance;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+2.5%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade300,
                        ),
                      ),
                      Text(
                        'ce mois',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          
          // Limite mensuelle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Limite mensuelle',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade100,
                      ),
                    ),
                    Text(
                      '€${userStatus['usedLimit']}/€${userStatus['monthlyLimit']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (userStatus['usedLimit'] as int) / (userStatus['monthlyLimit'] as int),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                if (userStatus['kycStatus'] != 'VERIFIED') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Complétez votre KYC pour augmenter vos limites',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade100,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
