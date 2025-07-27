import 'package:flutter/material.dart';
import '../models/country.dart';

class CountryPicker extends StatelessWidget {
  final Country selectedCountry;
  final Function(Country) onCountryChanged;

  const CountryPicker({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Simplifier le widget pour n'afficher que le drapeau et réduire l'empreinte
    return InkWell(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
        ),
        child: Text(
          selectedCountry.flag,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: const Text(
                'Sélectionner un pays',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Country.countries.length,
                itemBuilder: (context, index) {
                  final country = Country.countries[index];
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.code),
                    onTap: () {
                      onCountryChanged(country);
                      Navigator.pop(context);
                    },
                    selected: selectedCountry.code == country.code,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
