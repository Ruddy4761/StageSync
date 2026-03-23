import 'package:uuid/uuid.dart';

enum TaskStatus { notStarted, inProgress, done, delayed }

enum TaskPriority { high, medium, low }

class ConcertTask {
  final String id;
  String title;
  DateTime time;
  String assignedTo;
  TaskStatus status;
  TaskPriority priority;
  String? description;
  String concertId;

  ConcertTask({
    String? id,
    required this.title,
    required this.time,
    required this.assignedTo,
    this.status = TaskStatus.notStarted,
    this.priority = TaskPriority.medium,
    this.description,
    required this.concertId,
  }) : id = id ?? const Uuid().v4();

  String get statusLabel {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.delayed:
        return 'Delayed';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time.millisecondsSinceEpoch,
      'assignedTo': assignedTo,
      'status': status.name,
      'priority': priority.name,
      'description': description,
      'concertId': concertId,
    };
  }

  factory ConcertTask.fromMap(String id, Map<String, dynamic> map) {
    return ConcertTask(
      id: id,
      title: map['title'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),
      assignedTo: map['assignedTo'] ?? '',
      status: TaskStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TaskStatus.notStarted,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      description: map['description'],
      concertId: map['concertId'] ?? '',
    );
  }
}
