import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'expense_model.dart';
import 'app_state.dart';

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
  ExpenseCategory _selectedCategory = ExpenseCategory.dining;
  final Map<ExpenseCategory, IconData> _categoryIcons = {
    ExpenseCategory.dining: Icons.restaurant,
    ExpenseCategory.transport: Icons.directions_car,
    ExpenseCategory.shopping: Icons.shopping_cart,
    ExpenseCategory.entertainment: Icons.movie,
    ExpenseCategory.other: Icons.more_horiz,
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
            dialogTheme: DialogTheme(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
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
      // 移除 AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              // 改用 Column 而不是 ListView
              children: [
                // 添加返回按钮
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),

                // 主要内容使用 Expanded 和 SingleChildScrollView
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Amount field
                        Container(
                          margin: const EdgeInsets.only(bottom: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // 减小内边距
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).toInt()),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '金额',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.currency_yuan,
                                color: appState.accentColor,
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
                                    fontSize: 20, // 减小金额字体大小
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
                              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0), // 减小底部间距
                              child: Text(
                                '类别',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 6, // 减小芯片之间的间距
                              runSpacing: 6,
                              children: _categoryIcons.keys.map((category) {
                                final isSelected = _selectedCategory == category;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: FilterChip(
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0), // 进一步减小内边距
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _categoryIcons[category],
                                            size: 14, // 进一步减小图标
                                            color: isSelected ? colorScheme.onPrimary : appState.accentColor,
                                          ),
                                          const SizedBox(width: 2), // 减小图标和文字间距
                                          Text(
                                            category.toDisplayString(),
                                            style: TextStyle(
                                              fontSize: 12, // 减小文字大小
                                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    selected: isSelected,
                                    showCheckmark: false,
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    selectedColor: appState.accentColor,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0), // 调整圆角
                                    ),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 减小点击区域
                                    elevation: 0,
                                    padding: EdgeInsets.zero, // 移除默认内边距
                                    visualDensity: VisualDensity.compact, // 使用更紧凑的视觉密度
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20), // 增加类别和日期之间的间距

                        // Date Selection
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // 减小内边距
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).toInt()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outline.withAlpha((0.3 * 255).toInt())),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '日期',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2), // 减小间距
                                    Text(
                                      DateFormat('yyyy年MM月dd日').format(_selectedDate),
                                      style: TextStyle(
                                        fontSize: 14, // 减小字体大小
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.calendar_today, color: appState.accentColor),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20), // 增加日期和备注之间的间距

                        // Note field
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: '备注',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 减小输入框内边距
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withAlpha((0.5 * 255).toInt())),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: appState.accentColor, width: 2),
                            ),
                            prefixIcon: Icon(Icons.note_alt_outlined, color: colorScheme.onSurfaceVariant),
                            floatingLabelStyle: TextStyle(color: appState.accentColor),
                          ),
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurface), // 减小字体大小
                        ),

                        const SizedBox(height: 24), // 增加备注和保存按钮之间的间距
                      ],
                    ),
                  ),
                ),

                // Save button - 移到 Column 底部
                FilledButton.tonal(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(
                          context,
                          Expense(
                            // id
                            id: (DateTime.now().millisecondsSinceEpoch / 1000).round(),
                            time: _selectedDate,
                            amount: double.parse(_amountController.text),
                            category: _selectedCategory,
                            note: _noteController.text,
                          ));
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44), // 减小按钮高度
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('保存支出', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), // 减小字体大小
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
