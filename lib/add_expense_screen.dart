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
  final Map<String, IconData> _categoryIcons = {
    '餐饮': Icons.restaurant,
    '交通': Icons.directions_car,
    '购物': Icons.shopping_cart,
    '娱乐': Icons.movie,
    '其他': Icons.more_horiz,
  };

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新支出'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Amount field - More compact but still prominent
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('金额',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.currency_yuan, 
                        color: colorScheme.primary, 
                        size: 20,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          autofocus: true,
                          focusNode: _amountFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.end,
                          validator: (value) {
                            if (value == null || value.isEmpty) return '请输入金额';
                            if (double.tryParse(value) == null) return '请输入有效数字';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Category section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                      child: Text('类别',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: FilterChip(
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _categoryIcons[category],
                                    size: 20,
                                    color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            backgroundColor: colorScheme.surfaceVariant,
                            selectedColor: colorScheme.primary,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            elevation: isSelected ? 1 : 0,
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Date Selection
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('日期',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy年MM月dd日').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.calendar_today, color: colorScheme.primary),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Note field
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    prefixIcon: Icon(Icons.note_alt_outlined, color: colorScheme.onSurfaceVariant),
                    floatingLabelStyle: TextStyle(color: colorScheme.primary),
                  ),
                  maxLength: 50,
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                ),
                
                const SizedBox(height: 32),
                
                // Save button
                FilledButton.tonal(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(
                          context,
                          Expense(
                            id: DateTime.now().millisecondsSinceEpoch,
                            time: _selectedDate,
                            amount: double.parse(_amountController.text),
                            category: _selectedCategory,
                            note: _noteController.text,
                          ));
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('保存支出', 
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w500
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
