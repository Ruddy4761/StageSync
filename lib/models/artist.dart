import 'package:uuid/uuid.dart';

class Artist {
  final String id;
  String name;
  DateTime performanceTime;
  int durationMinutes;
  String? specialRequirements;
  int order;
  String concertId;

  Artist({
    String? id,
    required this.name,
    required this.performanceTime,
    required this.durationMinutes,
    this.specialRequirements,
    required this.order,
    required this.concertId,
  }) : id = id ?? const Uuid().v4();

  DateTime get endTime =>
      performanceTime.add(Duration(minutes: durationMinutes));

  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'performanceTime': performanceTime.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'specialRequirements': specialRequirements,
      'order': order,
      'concertId': concertId,
    };
  }

  factory Artist.fromMap(String id, Map<String, dynamic> map) {
    return Artist(
      id: id,
      name: map['name'] ?? '',
      performanceTime:
          DateTime.fromMillisecondsSinceEpoch(map['performanceTime'] ?? 0),
      durationMinutes: map['durationMinutes'] ?? 0,
      specialRequirements: map['specialRequirements'],
      order: map['order'] ?? 0,
      concertId: map['concertId'] ?? '',
    );
  }
}
