import 'package:flutter/material.dart';

class TransactionItem {
  final int id;
  final String type; // 'sent' ou 'received'
  final String amount;
  final String? recipient;
  final String? sender;
  final String country;
  final String status; // 'completed', 'pending', 'failed'
  final String paymentMethod;
  final String date;

  TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    this.recipient,
    this.sender,
    required this.country,
    required this.status,
    required this.paymentMethod,
    required this.date,
  });
}
