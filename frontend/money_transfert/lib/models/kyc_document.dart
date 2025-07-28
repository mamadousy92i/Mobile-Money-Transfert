class KycDocument {
  final int id;
  final String type;
  final String name;
  final String status;
  final String? uploadDate;

  KycDocument({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    this.uploadDate,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    return KycDocument(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      status: json['status'],
      uploadDate: json['upload_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'status': status,
      'upload_date': uploadDate,
    };
  }
}
