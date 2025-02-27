import 'package:intl/intl.dart';
import 'dart:convert';

class Expense {
  final DateTime time;
  final double amount;
  final String category;
  final String note;

  Expense({
    required this.time,
    required this.amount,
    required this.category,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': DateFormat('yyyy-MM-dd HH:mm').format(time),
      'amount': amount,
      'category': category,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      time: DateFormat('yyyy-MM-dd HH:mm').parse(map['time']),
      amount: map['amount'].toDouble(),
      category: map['category'],
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());
  factory Expense.fromJson(String source) => Expense.fromMap(json.decode(source));
}