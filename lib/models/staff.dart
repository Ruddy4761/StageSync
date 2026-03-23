import 'package:uuid/uuid.dart';

class Staff {
  final String id;
  String? userId;
  String name;
  String role;
  DateTime? shiftStart;
  DateTime? shiftEnd;
  String? contactNumber;
  String? avatarUrl;
  bool isCreator;
  String concertId;

  Staff({
    String? id,
    this.userId,
    required this.name,
    required this.role,
    this.shiftStart,
    this.shiftEnd,
    this.contactNumber,
    this.avatarUrl,
    this.isCreator = false,
    required this.concertId,
  }) : id = id ?? const Uuid().v4();

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get shiftFormatted {
    if (shiftStart == null || shiftEnd == null) return 'Not assigned';
    final startHour = shiftStart!.hour.toString().padLeft(2, '0');
    final startMin = shiftStart!.minute.toString().padLeft(2, '0');
    final endHour = shiftEnd!.hour.toString().padLeft(2, '0');
    final endMin = shiftEnd!.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'shiftStart': shiftStart?.millisecondsSinceEpoch,
      'shiftEnd': shiftEnd?.millisecondsSinceEpoch,
      'contactNumber': contactNumber,
      'avatarUrl': avatarUrl,
      'isCreator': isCreator,
      'concertId': concertId,
    };
  }

  factory Staff.fromMap(String id, Map<String, dynamic> map) {
    return Staff(
      id: id,
      userId: map['userId'],
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      shiftStart: map['shiftStart'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['shiftStart'])
          : null,
      shiftEnd: map['shiftEnd'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['shiftEnd'])
          : null,
      contactNumber: map['contactNumber'],
      avatarUrl: map['avatarUrl'],
      isCreator: map['isCreator'] ?? false,
      concertId: map['concertId'] ?? '',
    );
  }

  static const List<String> availableRoles = [
    'Event Manager',
    'Sound',
    'Lighting',
    'Security',
    'Stage Crew',
    'Volunteers',
    'Artist Manager',
  ];
}
