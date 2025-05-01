import 'package:expense_app/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'expense_model.dart';

class DailyReport {
  final double income;
  final double expense;

  DailyReport({required this.income, required this.expense});
}

class PieChartScreen extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;

  const PieChartScreen({super.key, required this.expenses, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <ExpenseCategory, double>{};
    double totalAmount = 0;

    for (var expense in expenses.where((e) => e.time.month == selectedMonth.month && e.time.year == selectedMonth.year)) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
      totalAmount += expense.amount;
    }

    final List<MapEntry<ExpenseCategory, double>> sortedEntries = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Define custom category colors
    final Map<ExpenseCategory, Color> categoryColors = {
      // ExpenseCategory.meals: const Color(0xFFF89D62), // Light orange for 三餐
      ExpenseCategory.snacks: const Color(0xFFFF7849), // Coral for 零食
      ExpenseCategory.entertainment: const Color(0xFF6ED69A), // Green for 娱乐
      // Add other categories with default colors
    };

    // Get color for category or use default color
    Color getCategoryColor(ExpenseCategory category, int index) {
      return categoryColors[category] ?? Colors.primaries[index % Colors.primaries.length];
    }

    final pieSections = sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final value = entry.value.value;
      final percentage = (value / totalAmount) * 100;
      final color = getCategoryColor(category, index);
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    // Generate daily report data
    Map<DateTime, DailyReport> dailyReports = _generateDailyReports();
    List<DateTime> sortedDays = dailyReports.keys.toList()..sort((a, b) => b.compareTo(a));

    double totalExpenseAmount = 0;
    int daysWithExpenses = 0;

    dailyReports.forEach((date, report) {
      if (report.expense > 0) {
        totalExpenseAmount += report.expense;
        daysWithExpenses++;
      }
    });

    // Calculate average daily expense
    double averageDailyExpense = daysWithExpenses > 0 ? totalExpenseAmount / daysWithExpenses : 0;

    return Container(
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.white,
            margin: const EdgeInsets.all(16.0),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '分类报表',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: pieSections,
                        centerSpaceRadius: 60,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 18.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('支出', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('收入', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedEntries.length,
                    itemBuilder: (context, index) {
                      final category = sortedEntries[index].key;
                      final amount = sortedEntries[index].value;
                      final percentage = (amount / totalAmount) * 100;
                      final color = getCategoryColor(category, index);
                      final categoryText = _getCategoryDisplayText(category);
                      final percentText = '${percentage.toStringAsFixed(2)}%';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: CategoryIcons.getIcon(category)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          categoryText,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        percentText,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 5,
                                    width: MediaQuery.of(context).size.width * percentage / 100 * 0.6,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '-${amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '日报表',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '日均支出: ${averageDailyExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          _buildTableCell('日期', isHeader: true),
                          _buildTableCell('收入', isHeader: true),
                          _buildTableCell('支出', isHeader: true),
                          _buildTableCell('结余', isHeader: true),
                        ],
                      ),
                      ...sortedDays.map((date) {
                        final report = dailyReports[date]!;
                        return TableRow(
                          children: [
                            _buildTableCell(DateFormat('MM-dd').format(date)),
                            _buildTableCell(report.income.toStringAsFixed(2), isPositive: report.income > 0),
                            _buildTableCell(report.expense.toStringAsFixed(2), isNegative: report.expense > 0),
                            _buildTableCell((report.income - report.expense).toStringAsFixed(2),
                                isPositive: report.income - report.expense > 0, isNegative: report.income - report.expense < 0),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      '到底了',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate daily reports for the selected month
  Map<DateTime, DailyReport> _generateDailyReports() {
    Map<DateTime, DailyReport> reports = {};

    // Filter expenses for selected month
    final monthlyExpenses = expenses.where((e) => e.time.month == selectedMonth.month && e.time.year == selectedMonth.year).toList();

    // Group by date
    for (var expense in monthlyExpenses) {
      final date = DateTime(expense.time.year, expense.time.month, expense.time.day);

      if (!reports.containsKey(date)) {
        reports[date] = DailyReport(income: 0, expense: 0);
      }

      final currentReport = reports[date]!;

      // Update the report based on expense type
      if (false) {
        reports[date] = DailyReport(income: currentReport.income + expense.amount, expense: currentReport.expense);
      } else {
        reports[date] = DailyReport(income: currentReport.income, expense: currentReport.expense + expense.amount.abs());
      }
    }

    return reports;
  }

  // Helper method to build table cells with appropriate styling
  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isNegative = false,
    bool isPositive = false,
  }) {
    Color textColor;

    if (isHeader) {
      textColor = Colors.black;
    } else if (isNegative) {
      textColor = Colors.red;
    } else if (isPositive) {
      textColor = Colors.green;
    } else {
      textColor = Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to get category display text
  String _getCategoryDisplayText(ExpenseCategory category) {
    switch (category) {
      // case ExpenseCategory.meals:
      //   return '三餐';
      case ExpenseCategory.snacks:
        return '零食';
      case ExpenseCategory.entertainment:
        return '娱乐';
      default:
        return category.toDisplayString();
    }
  }
}
