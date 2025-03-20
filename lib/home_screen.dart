import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expense_model.dart';
import 'add_expense_screen.dart';
import 'pie_chart_screen.dart';
import 'settings_screen.dart';
import 'app_state.dart';  // Add import for app state

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
    _initializeAppState();
  }

  Future<void> _initializeAppState() async {
    await appState.initialize();
    setState(() {});  // Refresh UI with loaded family ID
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
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final newList = [..._expenses, newExpense];
    await prefs.setStringList(
        _prefsKey, newList.map((e) => e.toJson()).toList());
    
    // Save to server
    try {
      final response = await http.post(
        Uri.parse('https://741096681b.azurewebsites.net/api/insert_expense?code=W_G0YXjFfMVtDcoAjE9v7mR1RYJb6f_HZFTmMl0R_aZwAzFur7KgPg=='),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': newExpense.id,
          'family': appState.familyId,  // Use the global family ID
          'category': newExpense.category.toInt(),
          'number': newExpense.amount,
          'remark': newExpense.note,
          'date_time': (newExpense.time.millisecondsSinceEpoch / 1000).round(), // Convert to epoch seconds
        }),
      );
      
      if (response.statusCode != 201) {
        log('Failed to save expense to server: ${response.body}');
      }
    } catch (e) {
      log('Error sending expense to server: $e');
    }
    
    setState(() => _expenses = newList);
  }

  Future<void> _deleteExpense(int expenseId) async { // Changed parameter to int
    setState(() {
      _expenses.removeWhere((expense) => expense.id == expenseId);
    });
    
    // 保存更新后的列表到SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _expenses.map((e) => e.toJson()).toList());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('支出已删除')),
      );
    }
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

  void _navigateToPieChartScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PieChartScreen(expenses: _expenses, selectedMonth: _selectedMonth),
      ),
    );
  }

  void _navigateToSettingsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
    // No need to explicitly reload family ID as it's stored in the global appState
    setState(() {});  // Refresh UI to reflect any changes
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _navigateToSettingsScreen,
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
                        return Dismissible(
                          key: Key(expense.id.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteExpense(expense.id); // Using int id
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          // Fix: Update the container to ensure corners are preserved
                          child: Container(
                            // Remove the color here as it overrides parent's borderRadius
                            // The last item needs to respect the parent container's border radius
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // Apply border radius only to the last item
                              borderRadius: index == entry.value.length - 1 
                                ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(12), 
                                    bottomRight: Radius.circular(12))
                                : null,
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.category.toDisplayString(),
                                    style: const TextStyle(
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
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
