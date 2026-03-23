import 'package:uuid/uuid.dart';

class EmergencyContact {
  final String id;
  String name;
  String role;
  String phoneNumber;
  String type; // 'medical', 'fire', 'police', 'venue', 'security', 'custom'
  String concertId;

  EmergencyContact({
    String? id,
    required this.name,
    required this.role,
    required this.phoneNumber,
    required this.type,
    required this.concertId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'type': type,
      'concertId': concertId,
    };
  }

  factory EmergencyContact.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyContact(
      id: id,
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      type: map['type'] ?? 'custom',
      concertId: map['concertId'] ?? '',
    );
  }
}
