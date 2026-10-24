import '../../../core/database/local_database.dart';

class AuthRepository {
  // Check if a user is currently registered & logged in
  static bool hasUser() {
    return LocalDatabase.getUser() != null;
  }

  // Get current registered user details
  static Map<String, dynamic>? currentUser() {
    return LocalDatabase.getUser();
  }

  // Register a new user local profile
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? referralCode,
  }) async {
    final userData = {
      'name': name,
      'email': email.trim(),
      'password': password,
      'phone': phone,
      'referralCode': referralCode ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    };

    final users = LocalDatabase.getUsersList();
    final existingIndex = users.indexWhere(
      (u) => (u['email'] as String?)?.toLowerCase().trim() == email.toLowerCase().trim(),
    );

    if (existingIndex >= 0) {
      users[existingIndex] = userData;
    } else {
      users.add(userData);
    }

    await LocalDatabase.saveUsersList(users);
    final saved = await LocalDatabase.saveUser(userData);
    if (saved && existingIndex < 0) {
      // Clean transactions for newly registered user
      await LocalDatabase.saveTransactions([]);
    }
    return saved;
  }

  // Google Login or Register
  static Future<bool> loginOrRegisterGoogleUser({
    required String name,
    required String email,
  }) async {
    final cleanEmail = email.trim();
    final users = LocalDatabase.getUsersList();
    final existingIndex = users.indexWhere(
      (u) => (u['email'] as String?)?.toLowerCase().trim() == cleanEmail.toLowerCase(),
    );

    Map<String, dynamic> userData;
    if (existingIndex >= 0) {
      userData = users[existingIndex];
      await LocalDatabase.saveUser(userData);
    } else {
      userData = {
        'name': name,
        'email': cleanEmail,
        'password': 'google_pos_auth',
        'phone': '+6281234567890',
        'referralCode': '',
        'authProvider': 'google',
        'createdAt': DateTime.now().toIso8601String(),
      };
      users.add(userData);
      await LocalDatabase.saveUsersList(users);
      await LocalDatabase.saveUser(userData);
      await LocalDatabase.saveTransactions([]);
    }

    return true;
  }

  // Authenticate user with stored local credentials
  static Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanInputEmail = email.toLowerCase().trim();
    final users = LocalDatabase.getUsersList();

    // Search in registered users list
    Map<String, dynamic>? matchedUser;
    for (final u in users) {
      final storedEmail = (u['email'] as String?)?.toLowerCase().trim();
      final storedPassword = u['password'] as String?;
      if (storedEmail == cleanInputEmail && storedPassword == password) {
        matchedUser = u;
        break;
      }
    }

    // Fallback for single-user legacy state if users list was not initialized
    if (matchedUser == null) {
      final singleUser = LocalDatabase.getUser();
      if (singleUser != null) {
        final storedEmail = (singleUser['email'] as String?)?.toLowerCase().trim();
        final storedPassword = singleUser['password'] as String?;
        if (storedEmail == cleanInputEmail && storedPassword == password) {
          matchedUser = singleUser;
          // Save to users list for future logins
          users.add(singleUser);
          await LocalDatabase.saveUsersList(users);
        }
      }
    }

    if (matchedUser != null) {
      await LocalDatabase.saveUser(matchedUser);
      return true;
    }

    return false;
  }

  // Clear current user session (Log out)
  static Future<void> logout() async {
    await LocalDatabase.clearUser();
  }
}
