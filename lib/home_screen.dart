import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:fl_chart/fl_chart.dart';

import 'expense_model.dart';
import 'add_expense_screen.dart';

const mainColor = Color.fromARGB(255, 247, 236, 236);




class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  final _prefsKey = 'expenses';
  DateTime _selectedMonth = DateTime.now();

  Map<DateTime, List<Expense>> _groupExpensesByDate() {
    final Map<DateTime, List<Expense>> grouped = {};
    for (var expense in _expenses.where((e) =>
        e.time.month == _selectedMonth.month &&
        e.time.year == _selectedMonth.year)) {
      final date = DateTime(
        expense.time.year,
        expense.time.month,
        expense.time.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(expense);
    }
    // Sort dates in descending order
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return Map.fromEntries(sortedEntries);
  }

  double _calculateMonthlyTotal() {
    return _expenses
        .where((expense) =>
            expense.time.month == _selectedMonth.month &&
            expense.time.year == _selectedMonth.year)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? items = prefs.getStringList(_prefsKey);

    if (items != null) {
      setState(() {
        _expenses = items.map((e) => Expense.fromJson(e)).toList();
      });
    }
  }

  Future<void> _addExpense(Expense newExpense) async {
    final prefs = await SharedPreferences.getInstance();
    final newList = [..._expenses, newExpense];
    await prefs.setStringList(
        _prefsKey, newList.map((e) => e.toJson()).toList());
    setState(() => _expenses = newList);
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 300,
          height: 400,
          child: MonthPicker.single(
            selectedDate: _selectedMonth,
            firstDate: DateTime(2020),
            onChanged: (date) {
              setState(() => _selectedMonth = date);
              Navigator.pop(context);
            },
            lastDate: DateTime.now().add(const Duration(days: 365)),
          ),
        ),
      ),
    );
  }

  void _navigateToPieChartScreen() {
    final entity = {
      'PartitionKey': 'partition1', // Replace with your partition key
      'RowKey': 'row1',             // Replace with your row key
      'Name': 'John Doe',           // Replace with your entity data
      'Age': 30,                    // Replace with your entity data
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PieChartScreen(expenses: _expenses, selectedMonth: _selectedMonth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _groupExpensesByDate();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: InkWell(
          onTap: _showMonthPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '月支出 ${_calculateMonthlyTotal().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 50),
              Text(
                DateFormat('yyyy-MM').format(_selectedMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: _navigateToPieChartScreen,
          ),
        ],
      ),
      body: Container(
        color: mainColor,
        child: ListView(
          children: [
            ..._groupExpensesByDate().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MM-dd').format(entry.key),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '支:${entry.value.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entry.value.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey[200],
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final expense = entry.value[index];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.category,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (expense.note.isNotEmpty)
                                Text(
                                  expense.note,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '¥${expense.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.red[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final result = await showModalBottomSheet<Expense?>(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddExpenseScreen(),
          );
          if (result != null) _addExpense(result);
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white,),
      ),
    );
  }
}

class PieChartScreen extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;

  const PieChartScreen({Key? key, required this.expenses, required this.selectedMonth}) : super(key: key);

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
      final color = Colors.primaries[categoryTotals.keys.toList().indexOf(entry.key) % Colors.primaries.length];
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
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
