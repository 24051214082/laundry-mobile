import 'package:flutter/foundation.dart';

/// Penyimpan data profil pelanggan yang dipakai bersama oleh semua halaman.
/// Instance-nya satu dan hidup selama aplikasi berjalan, jadi data tidak
/// hilang saat pindah halaman.
///
/// Nanti tinggal diisi dari session / API login, dan `update()` bisa
/// dihubungkan ke request update profil.
class UserProfileStore extends ChangeNotifier {
  UserProfileStore._();

  static final UserProfileStore instance = UserProfileStore._();

  String name = 'Zea Althafunissa';
  String phone = '+62 812-3456-7890';
  String email = 'zea.althaf@gmail.com';
  String address = 'Jl. Ketintang Baru No. 12, Surabaya';
  String avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';

  void update({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) {
    this.name = name;
    this.phone = phone;
    this.email = email;
    this.address = address;
    notifyListeners();
  }
}