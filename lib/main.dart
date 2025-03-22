import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_model.dart';
import 'dart:developer';
import 'app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.initialize();
  _loadInitialData();
  runApp(const MyApp());
}

Future<void> _loadInitialData() async {
  try {
    await fetchAndStoreExpenses();
    log('Successfully loaded initial expenses data', name: 'main');
  } catch (e) {
    log('Error during initial data loading: $e', name: 'main');
    // The app will continue running even if data loading fails
  }
}

Future<void> fetchAndStoreExpenses() async {
  try {

    // Replace with your actual API endpoint
    final response = await http.get(Uri.parse('https://741096681c.azurewebsites.net/api/get_expense/${appState.familyId}?code=pJQTZnTB45OGUtJrKYCkn3_XukHiAVgCgEYPLPcVlCDWAzFuU8lAVQ%3D%3D'));
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> expensesJson = jsonData['expenses'];
      
      final prefs = await SharedPreferences.getInstance();
      final existingExpensesJson = prefs.getStringList('expenses') ?? [];
      final existingExpenses = existingExpensesJson
          .map((e) => Expense.fromJson(e))
          .toList();
      
      // Convert server expenses to our Expense model
      final serverExpenses = expensesJson.map((e) {
        return Expense(
          id: e['id'], // Now using int directly
          category: ExpenseCategoryExtension.fromInt(e['category']),
          amount: e['number'].toDouble(),
          note: e['remark'].toString().replaceAll('"', ''),
          time: DateTime.fromMillisecondsSinceEpoch(e['data_time']*1000), // Using current time as the server data doesn't include time
          family: e['family']?.toString().trim() ?? '',
        );
      }).toList();
      
      // Merge with existing expenses (avoid duplicates by ID)
      final Map<int, Expense> mergedExpenses = {}; // Changed to int key
      
      // Add existing expenses to the map
      for (var expense in existingExpenses) {
        mergedExpenses[expense.id] = expense;
      }
      
      // Add/replace with server expenses
      for (var expense in serverExpenses) {
        mergedExpenses[expense.id] = expense;
      }
      
      // Save the merged expenses
      await prefs.setStringList(
        'expenses', 
        mergedExpenses.values.map((e) => e.toJson()).toList()
      );
    } else {
      log('Server returned status code ${response.statusCode}', name: 'fetchAndStoreExpenses');
    }
  } catch (e) {
    log('Error fetching expenses: $e', name: 'fetchAndStoreExpenses');
    // Allow the app to continue even if fetching fails
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
