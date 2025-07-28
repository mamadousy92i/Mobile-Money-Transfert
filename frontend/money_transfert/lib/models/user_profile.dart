class UserProfile {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final String memberSince;
  final String verificationLevel;
  final String kycStatus;
  final int documentsSubmitted;
  final int documentsRequired;
  final int totalTransactions;
  final String totalSent;

  UserProfile({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    required this.memberSince,
    required this.verificationLevel,
    required this.kycStatus,
    required this.documentsSubmitted,
    required this.documentsRequired,
    required this.totalTransactions,
    required this.totalSent,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'],
      memberSince: json['member_since'] ?? 'Mars 2025',
      verificationLevel: json['verification_level'] ?? 'Basic',
      kycStatus: json['kyc_status'] ?? 'NOT_STARTED',
      documentsSubmitted: json['documents_submitted'] ?? 0,
      documentsRequired: json['documents_required'] ?? 3,
      totalTransactions: json['total_transactions'] ?? 0,
      totalSent: json['total_sent'] ?? '€0',
    );
  }

  // Modèle par défaut pour les tests
  factory UserProfile.defaultProfile() {
    return UserProfile(
      firstName: 'Utilisateur',
      lastName: 'Test',
      email: 'utilisateur@example.com',
      phoneNumber: '+221 77 123 45 67',
      memberSince: 'Mars 2025',
      verificationLevel: 'Basic',
      kycStatus: 'PENDING',
      documentsSubmitted: 2,
      documentsRequired: 3,
      totalTransactions: 47,
      totalSent: '€12,847.50',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'member_since': memberSince,
      'verification_level': verificationLevel,
      'kyc_status': kycStatus,
      'documents_submitted': documentsSubmitted,
      'documents_required': documentsRequired,
      'total_transactions': totalTransactions,
      'total_sent': totalSent,
    };
  }

  String get fullName => '$firstName $lastName';
  
  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return 'U';
    return (firstName.isNotEmpty ? firstName[0] : '') + 
           (lastName.isNotEmpty ? lastName[0] : '');
  }
}
