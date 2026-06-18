import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Membaca status tema dari storage (default: false / terang)
  bool _loadTheme() => _box.read(_key) ?? false;

  // Menentukan tema apa yang akan dimuat saat aplikasi pertama dibuka
  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;

  // Fungsi toggle yang akan dipanggil di tombol pengaturan
  void switchTheme() {
    bool isDarkMode = _loadTheme();

    // Ubah tema di layar secara realtime
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);

    // Simpan pilihan terbaru ke storage
    _box.write(_key, !isDarkMode);
  }
}
