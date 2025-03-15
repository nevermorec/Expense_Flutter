
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'expense_model.dart';

class PieChartScreen extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;

  const PieChartScreen(
      {super.key, required this.expenses, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <String, double>{};
    double totalAmount = 0;

    for (var expense in expenses.where((e) =>
        e.time.month == selectedMonth.month &&
        e.time.year == selectedMonth.year)) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      totalAmount += expense.amount;
    }

    final pieSections = categoryTotals.entries.map((entry) {
      final percentage = (entry.value / totalAmount) * 100;
      final color = Colors.primaries[
          categoryTotals.keys.toList().indexOf(entry.key) %
              Colors.primaries.length];
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('分类支出饼图'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: PieChart(
          PieChartData(
            sections: pieSections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }
}