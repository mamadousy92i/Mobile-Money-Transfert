class Country {
  final String code;
  final String name;
  final String flag;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
  });

  static const List<Country> countries = [
    Country(code: '+221', name: 'Sénégal', flag: '🇸🇳'),
    Country(code: '+33', name: 'France', flag: '🇫🇷'),
    Country(code: '+1', name: 'États-Unis', flag: '🇺🇸'),
    Country(code: '+44', name: 'Royaume-Uni', flag: '🇬🇧'),
  ];
}
