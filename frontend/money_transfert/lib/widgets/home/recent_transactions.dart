import 'package:flutter/material.dart';

class TransactionItem {
  final int id;
  final String type; // 'sent' ou 'received'
  final String amount;
  final String recipient;
  final String? sender;
  final String country;
  final String status; // 'completed' ou 'pending'
  final String paymentMethod;
  final String date;

  TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    this.recipient = '',
    this.sender,
    required this.country,
    required this.status,
    required this.paymentMethod,
    required this.date,
  });
}

class RecentTransactionsCard extends StatelessWidget {
  final List<TransactionItem> transactions;
  final VoidCallback onViewAll;

  const RecentTransactionsCard({
    Key? key,
    required this.transactions,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: transactions.map((transaction) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TransactionListItem(transaction: transaction),
                  )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSent = transaction.type == 'sent';
    final Color iconBgColor = isSent ? Colors.red.shade100 : Colors.green.shade100;
    final Color iconColor = isSent ? Colors.red.shade600 : Colors.green.shade600;
    final String personName = isSent ? transaction.recipient : (transaction.sender ?? '');

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSent ? Icons.arrow_upward : Icons.arrow_downward,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      transaction.country,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      transaction.paymentMethod,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100),
              child: Text(
                transaction.amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSent ? Colors.red.shade600 : Colors.green.shade600,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100),
              child: Text(
                transaction.status == 'completed' ? 'Complété' : 'En cours',
                style: TextStyle(
                  color: transaction.status == 'completed'
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
