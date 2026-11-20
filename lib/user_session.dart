import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'realtime_notif_banner.dart';
import 'user_profile_store.dart';

class UserSession {
  static const String _storageKey = 'wish_you_wash_user_session';

  static String? userId;
  static String? name;
  static String? email;
  static String? phone;
  static String? address;
  static String? role;

  static bool get isLoggedIn => userId != null && userId!.isNotEmpty;

  static void _syncToProfileStore() {
    final store = UserProfileStore.instance;
    store.update(
      name: (name != null && name!.isNotEmpty) ? name! : store.name,
      email: (email != null && email!.isNotEmpty) ? email! : store.email,
      phone: (phone != null && phone!.isNotEmpty) ? phone! : store.phone,
      address: (address != null && address!.isNotEmpty) ? address! : store.address,
    );
  }

  static Future<void> setUser(Map<String, dynamic> user) async {
    userId = user['id']?.toString();
    name = user['name']?.toString();
    email = user['email']?.toString();
    phone = user['phone']?.toString();
    address = user['address']?.toString();
    role = user['role']?.toString();

    _syncToProfileStore();
    RealtimeNotifService.startListening();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user));
  }

  static Future<bool> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return false;

    final Map<String, dynamic> user = jsonDecode(raw);
    userId = user['id']?.toString();
    name = user['name']?.toString();
    email = user['email']?.toString();
    phone = user['phone']?.toString();
    address = user['address']?.toString();
    role = user['role']?.toString();

    _syncToProfileStore();
    if (isLoggedIn) {
      RealtimeNotifService.startListening();
    }
    return isLoggedIn;
  }

  static Future<void> clear() async {
    userId = null;
    name = null;
    email = null;
    phone = null;
    address = null;
    role = null;

    RealtimeNotifService.stopListening();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}