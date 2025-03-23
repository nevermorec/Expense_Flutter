import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AppState {
  // Singleton pattern
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Key for storing family ID in SharedPreferences
  static const String familyIdKey = 'family_id';

  // Default family ID
  String familyId = 'Family';

  final mainColor = Color.fromARGB(255, 247, 236, 236);

  final accentColor = Colors.blue;

  final _dataUpdateController = StreamController<void>.broadcast();
  Stream<void> get dataUpdates => _dataUpdateController.stream;

  // Initialize app state from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    familyId = prefs.getString(familyIdKey) ?? 'Family';
  }

  // Save family ID to SharedPreferences
  Future<void> saveFamilyId(String newFamilyId) async {
    familyId = newFamilyId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(familyIdKey, newFamilyId);
    notifyDataUpdated();
  }

  void notifyDataUpdated() {
    _dataUpdateController.add(null);
  }

  void dispose() {
    _dataUpdateController.close();
  }
}

// Global instance for easy access
final appState = AppState();
