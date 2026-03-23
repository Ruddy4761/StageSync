import 'package:uuid/uuid.dart';

enum IncidentType { sound, crowd, equipment, delay, other }

enum IncidentSeverity { low, medium, high }

enum IncidentStatus { open, inProgress, resolved }

class Incident {
  final String id;
  IncidentType type;
  String description;
  IncidentSeverity severity;
  DateTime time;
  IncidentStatus status;
  String? resolutionNotes;
  String concertId;

  Incident({
    String? id,
    required this.type,
    required this.description,
    required this.severity,
    DateTime? time,
    this.status = IncidentStatus.open,
    this.resolutionNotes,
    required this.concertId,
  })  : id = id ?? const Uuid().v4(),
        time = time ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case IncidentType.sound:
        return 'Sound';
      case IncidentType.crowd:
        return 'Crowd';
      case IncidentType.equipment:
        return 'Equipment';
      case IncidentType.delay:
        return 'Delay';
      case IncidentType.other:
        return 'Other';
    }
  }

  String get severityLabel {
    switch (severity) {
      case IncidentSeverity.low:
        return 'Low';
      case IncidentSeverity.medium:
        return 'Medium';
      case IncidentSeverity.high:
        return 'High';
    }
  }

  String get statusLabel {
    switch (status) {
      case IncidentStatus.open:
        return 'Open';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'description': description,
      'severity': severity.name,
      'time': time.millisecondsSinceEpoch,
      'status': status.name,
      'resolutionNotes': resolutionNotes,
      'concertId': concertId,
    };
  }

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    return Incident(
      id: id,
      type: IncidentType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => IncidentType.other,
      ),
      description: map['description'] ?? '',
      severity: IncidentSeverity.values.firstWhere(
        (s) => s.name == map['severity'],
        orElse: () => IncidentSeverity.low,
      ),
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),
      status: IncidentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => IncidentStatus.open,
      ),
      resolutionNotes: map['resolutionNotes'],
      concertId: map['concertId'] ?? '',
    );
  }
}
