import 'package:uuid/uuid.dart';

class Note {
  final String id;
  String message;
  String authorName;
  String? authorId;
  DateTime timestamp;
  bool isPinned;
  String concertId;

  Note({
    String? id,
    required this.message,
    required this.authorName,
    this.authorId,
    DateTime? timestamp,
    this.isPinned = false,
    required this.concertId,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'authorName': authorName,
      'authorId': authorId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isPinned': isPinned,
      'concertId': concertId,
    };
  }

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      message: map['message'] ?? '',
      authorName: map['authorName'] ?? '',
      authorId: map['authorId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isPinned: map['isPinned'] ?? false,
      concertId: map['concertId'] ?? '',
    );
  }
}
