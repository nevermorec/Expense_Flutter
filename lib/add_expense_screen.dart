import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '餐饮';
  final List<String> _categories = ['餐饮', '交通', '购物', '娱乐', '其他'];

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加新支出')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('类别', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final Map<String, IconData> categoryIcons = {
                          '餐饮': Icons.restaurant,
                          '交通': Icons.directions_car,
                          '购物': Icons.shopping_cart,
                          '娱乐': Icons.movie,
                          '其他': Icons.more_horiz,
                        };
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryIcons[category],
                                size: 18,
                                color: _selectedCategory == category
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 4),
                              Text(category),
                            ],
                          ),
                          selected: _selectedCategory == category,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          showCheckmark: false,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          shape: const StadiumBorder(),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('时间', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                autofocus: true,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: '金额',
                  prefixIcon: const Icon(Icons.currency_yuan),
                  hintText: '0.00',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: const OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.end,
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入金额';
                  if (double.tryParse(value) == null) return '请输入有效数字';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                        context,
                        Expense(
                          time: _selectedDate,
                          amount: double.parse(_amountController.text),
                          category: _selectedCategory,
                          note: _noteController.text,
                        ));
                  }
                },
                child: const Text('保存支出', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
