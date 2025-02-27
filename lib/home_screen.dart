import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';

import 'expense_model.dart';
import 'add_expense_screen.dart';

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
    for (var expense in _expenses) {
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

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _groupExpensesByDate();
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: _showMonthPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '总支出 ${_calculateMonthlyTotal().toStringAsFixed(2)}',
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
      ),
      body: ListView(
        children: [
          ..._groupExpensesByDate().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(entry.key),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
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
                        title: Text('¥${expense.amount.toStringAsFixed(2)}'),
                        subtitle: Text(expense.category),
                        trailing: SizedBox(
                          width: 120,
                          child: Text(
                            expense.note,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Expense?>(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          if (result != null) _addExpense(result);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
