import 'dart:developer';
import 'dart:async'; // Add this import
import 'package:flutter/services.dart'; // Add this import for SystemUiOverlayStyle

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expense_model.dart';
import 'add_expense_screen.dart';
import 'pie_chart_screen.dart';
import 'settings_screen.dart';
import 'app_state.dart'; // Add import for app state
import 'category_icons.dart'; // Add import for category icons

const mainColor = Colors.lightBlue;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  final _prefsKey = 'expenses';
  DateTime _selectedMonth = DateTime.now();
  late StreamSubscription _dataUpdateSubscription;
  int _selectedIndex = 0;

  Map<DateTime, List<Expense>> _groupExpensesByDate() {
    final Map<DateTime, List<Expense>> grouped = {};
    for (var expense in _expenses.where((e) => e.time.month == _selectedMonth.month && e.time.year == _selectedMonth.year)) {
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
    final sortedEntries = grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    return Map.fromEntries(sortedEntries);
  }

  double _calculateMonthlyTotal() {
    return _expenses
        .where((expense) => expense.time.month == _selectedMonth.month && expense.time.year == _selectedMonth.year)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _initializeAppState();
    _dataUpdateSubscription = appState.dataUpdates.listen((_) {
      _loadExpenses();
    });
  }

  @override
  void dispose() {
    _dataUpdateSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeAppState() async {
    await appState.initialize();
    setState(() {});
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
    setState(() {
      _expenses = [..._expenses, newExpense];
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _expenses.map((e) => e.toJson()).toList());

    try {
      final response = await http.post(
        Uri.parse('https://741096681c.azurewebsites.net/api/add_expense?code=UrW2LL7OQg7iV8ZXCoXXB5VLzbEpOBMmgkub9lcD3si1AzFuW_3EaA%3D%3D'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': newExpense.id,
          'family': appState.familyId,
          'category': newExpense.category.toInt(),
          'number': newExpense.amount,
          'remark': newExpense.note,
          'date_time': (newExpense.time.millisecondsSinceEpoch / 1000).round(),
        }),
      );

      if (response.statusCode != 201) {
        log('Failed to save expense to server: ${response.body}');
      }
    } catch (e) {
      log('Error sending expense to server: $e');
    }
  }

  Future<void> _deleteExpense(int expenseId) async {
    setState(() {
      _expenses.removeWhere((expense) => expense.id == expenseId);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _expenses.map((e) => e.toJson()).toList());

    http.get(Uri.parse(
        'https://741096681c.azurewebsites.net/api/delete_expense/${expenseId.toString()}/${appState.familyId}?code=-SVXDqgYhYaPPodhMD74Lh0FHSvTYnDmC2EZZwY05U2PAzFuJEzxYA%3D%3D'));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('支出已删除'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply system UI overlay style to match navigation bar with bottom bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, // Match with BottomNavigationBar color
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: (_selectedIndex == 0 || _selectedIndex == 1)
          ? AppBar(
              backgroundColor: mainColor,
              elevation: 0,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: mainColor,
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 22),
                          onPressed: () => _changeMonth(-1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.white,
                        ),
                        GestureDetector(
                          onTap: _showMonthPicker,
                          child: Text(
                            DateFormat('yyyy-MM').format(_selectedMonth),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 22),
                          onPressed: () => _changeMonth(1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          PieChartScreen(expenses: _expenses, selectedMonth: _selectedMonth),
          _buildWalletContent(),
          _buildSettingsContent(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Container(
              width: 56,
              height: 56,
              margin: const EdgeInsets.only(right: 10, bottom: 10),
              child: Material(
                color: mainColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final result = await showModalBottomSheet<Expense?>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const AddExpenseScreen(),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.95,
                      ),
                    );
                    if (result != null) _addExpense(result);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        iconSize: 28.0, // Increased icon size
        backgroundColor: Colors.white, // Explicitly set background color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      color: mainColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '月支出',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '￥${_calculateMonthlyTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                children: [
                  ..._expenses.where((e) => e.time.month == _selectedMonth.month && e.time.year == _selectedMonth.year).take(10).map((expense) {
                    return Dismissible(
                      key: Key(expense.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteExpense(expense.id);
                      },
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            child: _getCategoryIcon(expense.category),
                          ),
                          title: Text(
                            expense.category.toDisplayString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('MM-dd').format(expense.time),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            expense.amount > 0 ? '+${expense.amount.toStringAsFixed(2)}' : '-\$${expense.amount.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: expense.amount > 0 ? Colors.green : Colors.red[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletContent() {
    // Placeholder for wallet screen
    return Center(
      child: Text(
        '钱包页面',
        style: TextStyle(fontSize: 24, color: mainColor),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return const SettingsScreen();
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
        1,
      );
    });
  }

  void _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Widget _getCategoryIcon(ExpenseCategory category) {
    return CategoryIcons.getIcon(category, color: mainColor);
  }
}
