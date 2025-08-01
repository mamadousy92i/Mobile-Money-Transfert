// lib/providers/payment_channel_provider.dart
import 'package:flutter/material.dart';
import '../models/payment_channel_model.dart';
import '../services/payment_channel_service.dart';

class PaymentChannelProvider with ChangeNotifier {
  final PaymentChannelService _channelService;
  List<PaymentChannel> _channels = [];
  bool _isLoading = false;

  PaymentChannelProvider(this._channelService);

  List<PaymentChannel> get channels => _channels;
  bool get isLoading => _isLoading;

  Future<void> fetchPaymentChannels() async {
    _isLoading = true;
    notifyListeners();
    try {
      _channels = await _channelService.getChannels();
    } catch (e) {
      print("Erreur fetchPaymentChannels: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}