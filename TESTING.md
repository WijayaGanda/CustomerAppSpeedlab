# Testing Documentation - SpeedLab Pelanggan

## Overview
Dokumentasi ini menjelaskan cara menjalankan widget testing dan integration testing untuk fitur Login dan Register di aplikasi SpeedLab Pelanggan.

## Struktur Testing

### Widget Tests
Widget tests terletak di folder `test/`:
- `test/login_view_test.dart` - Testing untuk tampilan login
- `test/register_view_test.dart` - Testing untuk tampilan register

### Integration Tests
Integration tests terletak di folder `integration_test/`:
- `integration_test/login_integration_test.dart` - Testing alur login lengkap
- `integration_test/register_integration_test.dart` - Testing alur register lengkap
- `integration_test/driver.dart` - Driver untuk menjalankan integration test

## Prerequisites

Pastikan dependency testing sudah terinstall. Jalankan command berikut:

```bash
flutter pub get
```

Dependencies yang dibutuhkan (sudah ditambahkan di pubspec.yaml):
- `flutter_test` - Testing framework Flutter
- `integration_test` - Integration testing
- `mockito` - Mocking framework
- `build_runner` - Code generation untuk mocks

## Generate Mock Files

Sebelum menjalankan widget tests, generate mock files terlebih dahulu:

```bash
# Generate mocks untuk login view test
flutter pub run build_runner build --delete-conflicting-outputs

# Atau menggunakan watch mode untuk auto-generate
flutter pub run build_runner watch
```

## Menjalankan Widget Tests

### Menjalankan Semua Widget Tests
```bash
flutter test
```

### Menjalankan Test Spesifik

**Login View Test:**
```bash
flutter test test/login_view_test.dart
```

**Register View Test:**
```bash
flutter test test/register_view_test.dart
```

### Menjalankan Test dengan Verbose Output
```bash
flutter test --reporter expanded
```

## Menjalankan Integration Tests

### Menjalankan di Device/Emulator

Pastikan device atau emulator sudah terhubung:
```bash
flutter devices
```

**Login Integration Test:**
```bash
flutter test integration_test/login_integration_test.dart
```

**Register Integration Test:**
```bash
flutter test integration_test/register_integration_test.dart
```

### Menjalankan Semua Integration Tests
```bash
flutter test integration_test/
```

### Menjalankan dengan Device Spesifik
```bash
flutter test integration_test/ -d <device_id>
```

## Test Coverage

### Login View Tests
Widget tests mencakup:
- ✅ Menampilkan semua widget yang diperlukan
- ✅ Toggle visibility password
- ✅ Validasi field kosong
- ✅ Input email dan password
- ✅ Navigasi ke halaman lupa password
- ✅ Loading indicator
- ✅ Tombol login dengan kredensial valid

### Register View Tests
Widget tests mencakup:
- ✅ Menampilkan semua widget yang diperlukan
- ✅ Toggle visibility password
- ✅ Validasi field kosong
- ✅ Input semua field (nama, email, password, phone, address)
- ✅ Loading indicator
- ✅ Scrolling content
- ✅ Multi-field input validation

### Login Integration Tests
Integration tests mencakup:
- ✅ Alur login lengkap dengan kredensial valid
- ✅ Login dengan field kosong
- ✅ Toggle password visibility
- ✅ Navigasi ke forgot password
- ✅ Google sign-in button visibility
- ✅ Form scrolling
- ✅ Validasi format email
- ✅ Input password

### Register Integration Tests
Integration tests mencakup:
- ✅ Alur registrasi lengkap dengan data valid
- ✅ Registrasi dengan field kosong
- ✅ Registrasi dengan data parsial
- ✅ Toggle password visibility
- ✅ Input semua field
- ✅ Form scrolling
- ✅ Validasi format email dan phone
- ✅ Navigasi back button

## Troubleshooting

### Mock Files Not Found
Jika mendapat error "...mocks.dart not found", jalankan:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Integration Test Failed
Pastikan:
1. Device/emulator sudah terhubung
2. API endpoint dapat diakses (jika testing dengan backend)
3. Dependencies sudah terinstall lengkap

### Test Timeout
Tambahkan timeout di test:
```dart
testWidgets('test name', (WidgetTester tester) async {
  // test code
}, timeout: const Timeout(Duration(minutes: 2)));
```

## Best Practices

1. **Jalankan tests secara berkala** - Jalankan setelah setiap perubahan kode
2. **Mock dependencies** - Gunakan mocks untuk isolasi unit tests
3. **Clean test data** - Reset state setelah setiap test
4. **Gunakan meaningful test names** - Nama test harus jelas dan deskriptif
5. **Test happy path dan edge cases** - Test skenario sukses dan error

## Continuous Integration

Untuk CI/CD, tambahkan di pipeline:

```yaml
# Example for GitHub Actions
- name: Run tests
  run: |
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs
    flutter test
    flutter test integration_test/
```

## Contact

Jika ada pertanyaan atau issues, silakan hubungi tim development.
