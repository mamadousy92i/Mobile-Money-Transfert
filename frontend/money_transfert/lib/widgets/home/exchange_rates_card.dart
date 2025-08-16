import 'package:flutter/material.dart';

class CurrencyRate {
  final String code;
  final String flag;
  final double rate;
  final double change;

  CurrencyRate({
    required this.code,
    required this.flag,
    required this.rate,
    required this.change,
  });

  bool get isPositive => change >= 0;
}

class ExchangeRatesCard extends StatelessWidget {
  final List<CurrencyRate> rates;

  const ExchangeRatesCard({
    Key? key,
    required this.rates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Taux de change en direct',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...rates.map((rate) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CurrencyRateItem(rate: rate),
                )),
          ],
        ),
      ),
    );
  }
}

class CurrencyRateItem extends StatelessWidget {
  final CurrencyRate rate;

  const CurrencyRateItem({
    Key? key,
    required this.rate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            rate.flag,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          rate.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rate.rate.toStringAsFixed(4),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${rate.isPositive ? '+' : ''}${rate.change.toStringAsFixed(2)}%',
              style: TextStyle(
                color: rate.isPositive ? Colors.green.shade600 : Colors.red.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
