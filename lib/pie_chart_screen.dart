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
    final categoryTotals = <ExpenseCategory, double>{};
    double totalAmount = 0;

    for (var expense in expenses.where((e) =>
        e.time.month == selectedMonth.month &&
        e.time.year == selectedMonth.year)) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      totalAmount += expense.amount;
    }

    final List<MapEntry<ExpenseCategory, double>> sortedEntries = 
        categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    final pieSections = sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value;
      final percentage = (value / totalAmount) * 100;
      final color = Colors.primaries[index % Colors.primaries.length];
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('分类支出饼图'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${selectedMonth.year}年${selectedMonth.month}月支出总计: ¥${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  final category = sortedEntries[index].key;
                  final amount = sortedEntries[index].value;
                  final percentage = (amount / totalAmount) * 100;
                  final color = Colors.primaries[index % Colors.primaries.length];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.toDisplayString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          '¥${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}