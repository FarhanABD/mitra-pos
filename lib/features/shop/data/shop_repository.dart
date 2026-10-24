import '../../../core/database/local_database.dart';

class ShopRepository {
  // Check if store profile is already configured
  static bool hasShop() {
    return LocalDatabase.getShop() != null;
  }

  // Get current store details
  static Map<String, dynamic>? currentShop() {
    return LocalDatabase.getShop();
  }

  // Save/configure store profile
  static Future<bool> saveShop({
    required String businessType,
    required String name,
    required String country,
    required String province,
    required String city,
    required String address,
  }) async {
    final shopData = {
      'businessType': businessType,
      'name': name,
      'country': country,
      'province': province,
      'city': city,
      'address': address,
      'isLocationPinned': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    return LocalDatabase.saveShop(shopData);
  }
}
