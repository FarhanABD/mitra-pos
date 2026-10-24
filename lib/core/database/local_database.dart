import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static const String _keyUser = 'user_data';
  static const String _keyUsersList = 'registered_users_list';
  static const String _keyShop = 'shop_data';
  static const String _keyProducts = 'products_data';
  static const String _keyCategories = 'categories_data';
  static const String _keyTransactions = 'transactions_data';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Auth / User Operations ---
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    await _initCheck();
    return _prefs!.setString(_keyUser, jsonEncode(userData));
  }

  static Map<String, dynamic>? getUser() {
    final raw = _prefs?.getString(_keyUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<bool> clearUser() async {
    await _initCheck();
    return _prefs!.remove(_keyUser);
  }

  // Registered Accounts List
  static Future<bool> saveUsersList(List<Map<String, dynamic>> users) async {
    await _initCheck();
    return _prefs!.setString(_keyUsersList, jsonEncode(users));
  }

  static List<Map<String, dynamic>> getUsersList() {
    final raw = _prefs?.getString(_keyUsersList);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Helper to isolate data per registered user ---
  static String _getUserScopedKey(String baseKey) {
    final user = getUser();
    if (user != null && user['email'] != null) {
      final emailClean = (user['email'] as String).toLowerCase().trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      return '${baseKey}_$emailClean';
    }
    return baseKey;
  }

  // --- Shop Operations ---
  static Future<bool> saveShop(Map<String, dynamic> shopData) async {
    await _initCheck();
    final user = getUser();
    if (user != null && user['email'] != null) {
      shopData['userEmail'] = user['email'];
    }
    final scopedKey = _getUserScopedKey(_keyShop);
    await _prefs!.setString(scopedKey, jsonEncode(shopData));
    return _prefs!.setString(_keyShop, jsonEncode(shopData));
  }

  static Map<String, dynamic>? getShop() {
    final scopedKey = _getUserScopedKey(_keyShop);
    final rawScoped = _prefs?.getString(scopedKey);
    if (rawScoped != null) {
      return jsonDecode(rawScoped) as Map<String, dynamic>;
    }
    // Fallback: check legacy shop key if it matches current user
    final rawLegacy = _prefs?.getString(_keyShop);
    if (rawLegacy != null) {
      final decoded = jsonDecode(rawLegacy) as Map<String, dynamic>;
      final currentUserEmail = (getUser()?['email'] as String?)?.toLowerCase().trim();
      final shopEmail = (decoded['userEmail'] as String?)?.toLowerCase().trim();
      if (shopEmail == null || shopEmail == currentUserEmail) {
        return decoded;
      }
    }
    return null;
  }

  static Future<bool> clearShop() async {
    await _initCheck();
    final scopedKey = _getUserScopedKey(_keyShop);
    await _prefs!.remove(scopedKey);
    return _prefs!.remove(_keyShop);
  }

  // --- Product Operations ---
  static Future<bool> saveProducts(List<Map<String, dynamic>> products) async {
    await _initCheck();
    final scopedKey = _getUserScopedKey(_keyProducts);
    await _prefs!.setString(scopedKey, jsonEncode(products));
    return _prefs!.setString(_keyProducts, jsonEncode(products));
  }

  static List<Map<String, dynamic>>? getProducts() {
    final scopedKey = _getUserScopedKey(_keyProducts);
    final rawScoped = _prefs?.getString(scopedKey);
    if (rawScoped != null) {
      final List<dynamic> decoded = jsonDecode(rawScoped);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    final rawLegacy = _prefs?.getString(_keyProducts);
    if (rawLegacy == null) return null;
    final List<dynamic> decoded = jsonDecode(rawLegacy);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Category Operations ---
  static Future<bool> saveCategories(List<String> categories) async {
    await _initCheck();
    final scopedKey = _getUserScopedKey(_keyCategories);
    await _prefs!.setString(scopedKey, jsonEncode(categories));
    return _prefs!.setString(_keyCategories, jsonEncode(categories));
  }

  static List<String>? getCategories() {
    final scopedKey = _getUserScopedKey(_keyCategories);
    final rawScoped = _prefs?.getString(scopedKey);
    if (rawScoped != null) {
      final List<dynamic> decoded = jsonDecode(rawScoped);
      return decoded.map((e) => e.toString()).toList();
    }
    final rawLegacy = _prefs?.getString(_keyCategories);
    if (rawLegacy == null) return null;
    final List<dynamic> decoded = jsonDecode(rawLegacy);
    return decoded.map((e) => e.toString()).toList();
  }

  // --- Transaction Operations ---
  static Future<bool> saveTransactions(List<Map<String, dynamic>> transactions) async {
    await _initCheck();
    final scopedKey = _getUserScopedKey(_keyTransactions);
    return _prefs!.setString(scopedKey, jsonEncode(transactions));
  }

  static List<Map<String, dynamic>>? getTransactions() {
    final scopedKey = _getUserScopedKey(_keyTransactions);
    final raw = _prefs?.getString(scopedKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // Reset or clear transactions for current user
  static Future<void> clearCurrentUserTransactions() async {
    await _initCheck();
    final scopedKey = _getUserScopedKey(_keyTransactions);
    await _prefs!.remove(scopedKey);
    // Also remove legacy transactions key so old mock data is wiped
    await _prefs!.remove(_keyTransactions);
  }

  // Helper init checker
  static Future<void> _initCheck() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
