import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  String category;
  double amount;
  String description;
  DateTime date;
  String concertId;

  Expense({
    String? id,
    required this.category,
    required this.amount,
    required this.description,
    DateTime? date,
    required this.concertId,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'concertId': concertId,
    };
  }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      concertId: map['concertId'] ?? '',
    );
  }

  static const List<String> categories = [
    'Venue',
    'Equipment',
    'Staff',
    'Artist Fees',
    'Marketing',
    'Other',
  ];
}
