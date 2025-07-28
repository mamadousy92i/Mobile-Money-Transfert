class Beneficiary {
  final int id;
  final String name;
  final String phone;
  final String country;
  final String flag;
  final String lastUsed;
  final bool favorite;

  Beneficiary({
    required this.id,
    required this.name,
    required this.phone,
    required this.country,
    required this.flag,
    required this.lastUsed,
    this.favorite = false,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      country: json['country'],
      flag: json['flag'],
      lastUsed: json['last_used'],
      favorite: json['favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'country': country,
      'flag': flag,
      'last_used': lastUsed,
      'favorite': favorite,
    };
  }
}
