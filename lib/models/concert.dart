import 'package:uuid/uuid.dart';

class Concert {
  final String id;
  String name;
  DateTime dateTime;
  String venue;
  List<String> artistNames;
  int capacity;
  String creatorRole;
  String creatorName;
  String? creatorId;
  String joinCode;
  double totalBudget;
  String status; // 'upcoming', 'ongoing', 'completed'
  List<String> memberIds;

  Concert({
    String? id,
    required this.name,
    required this.dateTime,
    required this.venue,
    this.artistNames = const [],
    required this.capacity,
    required this.creatorRole,
    required this.creatorName,
    this.creatorId,
    String? joinCode,
    this.totalBudget = 0,
    this.status = 'upcoming',
    List<String>? memberIds,
  })  : id = id ?? const Uuid().v4(),
        joinCode = joinCode ?? _generateJoinCode(),
        memberIds = memberIds ?? [];

  static String _generateJoinCode() {
    const uuid = Uuid();
    final code = uuid.v4().substring(0, 6).toUpperCase();
    return code;
  }

  int get daysUntilEvent {
    return dateTime.difference(DateTime.now()).inDays;
  }

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  bool get isPast => dateTime.isBefore(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'venue': venue,
      'artistNames': artistNames,
      'capacity': capacity,
      'creatorRole': creatorRole,
      'creatorName': creatorName,
      'creatorId': creatorId,
      'joinCode': joinCode,
      'totalBudget': totalBudget,
      'status': status,
      'memberIds': memberIds,
    };
  }

  factory Concert.fromMap(String id, Map<String, dynamic> map) {
    return Concert(
      id: id,
      name: map['name'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] ?? 0),
      venue: map['venue'] ?? '',
      artistNames: List<String>.from(map['artistNames'] ?? []),
      capacity: map['capacity'] ?? 0,
      creatorRole: map['creatorRole'] ?? '',
      creatorName: map['creatorName'] ?? '',
      creatorId: map['creatorId'],
      joinCode: map['joinCode'] ?? '',
      totalBudget: (map['totalBudget'] ?? 0).toDouble(),
      status: map['status'] ?? 'upcoming',
      memberIds: List<String>.from(map['memberIds'] ?? []),
    );
  }
}
