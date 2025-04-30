import 'package:flutter/material.dart';
import 'expense_model.dart';

/// Shared category icon configuration used across the app
class CategoryIcons {
  static const Map<ExpenseCategory, IconData> icons = {
    ExpenseCategory.dining: Icons.fastfood,
    ExpenseCategory.transport: Icons.directions_car,
    ExpenseCategory.shopping: Icons.shopping_bag,
    ExpenseCategory.medical: Icons.local_hospital,
    ExpenseCategory.entertainment: Icons.movie,
    ExpenseCategory.snacks: Icons.icecream,
    ExpenseCategory.clothing: Icons.checkroom,
    ExpenseCategory.internet: Icons.wifi,
    ExpenseCategory.housing: Icons.home,
    ExpenseCategory.digital: Icons.devices,
    ExpenseCategory.other: Icons.more_horiz,
  };

  /// Get an icon for a specific expense category
  static Icon getIcon(ExpenseCategory category, {Color? color, double? size}) {
    return Icon(
      icons[category] ?? Icons.payments,
      color: color ?? Colors.blue,
      size: size ?? 24.0,
    );
  }
}
