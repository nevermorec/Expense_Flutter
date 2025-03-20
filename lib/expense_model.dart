import 'package:intl/intl.dart';
import 'dart:convert';

// Expense Category Enum
enum ExpenseCategory {
  dining,     // 餐饮
  transport,  // 交通
  shopping,   // 购物
  medical,    // 医疗
  entertainment, // 娱乐
  other,      // 其他
}

// Extension for ExpenseCategory to add conversion methods
extension ExpenseCategoryExtension on ExpenseCategory {
  // Convert enum to int
  int toInt() => index;
  
  // Convert enum to display string
  String toDisplayString() {
    switch (this) {
      case ExpenseCategory.dining: return '餐饮';
      case ExpenseCategory.transport: return '交通';
      case ExpenseCategory.shopping: return '购物';
      case ExpenseCategory.medical: return '医疗';
      case ExpenseCategory.entertainment: return '娱乐';
      case ExpenseCategory.other: return '其他';
    }
  }
  
  // Get enum from string
  static ExpenseCategory fromString(String name) {
    switch (name) {
      case '餐饮': return ExpenseCategory.dining;
      case '交通': return ExpenseCategory.transport;
      case '购物': return ExpenseCategory.shopping;
      case '医疗': return ExpenseCategory.medical;
      case '娱乐': return ExpenseCategory.entertainment;
      case '其他': return ExpenseCategory.other;
      default: return ExpenseCategory.other;
    }
  }
  
  // Get enum from int
  static ExpenseCategory fromInt(int index) {
    return ExpenseCategory.values[index >= 0 && index < ExpenseCategory.values.length ? index : ExpenseCategory.other.index];
  }
}

class Expense {
  final int id;
  final DateTime time;
  final double amount;
  final ExpenseCategory category;  // Changed from String to ExpenseCategory
  final String note;
  final String family;

  Expense({
    required this.id,
    required this.time,
    required this.amount,
    required this.category,
    required this.note,
    this.family = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': DateFormat('yyyy-MM-dd HH:mm').format(time),
      'amount': amount,
      'category': category.toInt(),  // Convert enum to int for storage
      'note': note,
      'family': family,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    // Handle category conversion from either int or string
    ExpenseCategory categoryFromMap;
    if (map['category'] is int) {
      categoryFromMap = ExpenseCategoryExtension.fromInt(map['category']);
    } else if (map['category'] is String) {
      // Try to parse as int first if it looks like a number
      if (int.tryParse(map['category']) != null) {
        categoryFromMap = ExpenseCategoryExtension.fromInt(int.parse(map['category']));
      } else {
        categoryFromMap = ExpenseCategoryExtension.fromString(map['category']);
      }
    } else {
      categoryFromMap = ExpenseCategory.other;
    }
    
    return Expense(
      id: map['id'] is String ? int.parse(map['id']) : map['id'] as int,
      time: map['time'] is String 
          ? DateFormat('yyyy-MM-dd HH:mm').parse(map['time'])
          : DateTime.fromMillisecondsSinceEpoch(map['time']),
      amount: (map['amount'] ?? 0).toDouble(),
      category: categoryFromMap,
      note: map['note'] ?? '',
      family: map['family'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory Expense.fromJson(String source) =>
      Expense.fromMap(json.decode(source));
}
