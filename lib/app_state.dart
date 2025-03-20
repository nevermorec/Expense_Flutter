
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  // Singleton pattern
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Key for storing family ID in SharedPreferences
  static const String familyIdKey = 'family_id';
  
  // Default family ID
  String familyId = 'Family';

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
  }
}

// Global instance for easy access
final appState = AppState();