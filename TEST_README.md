# 📝 Penjelasan Testing - FAQ

## ❓ Kenapa Error Image?

### Masalah:
```
NetworkImageLoadException: HTTP request failed, statusCode: 400
```

### Penyebab:
1. **LoginView** menggunakan `Image.network()` untuk load logo Google dari internet
2. Dalam environment testing, `TestWidgetsFlutterBinding` **memblokir semua HTTP request** dan mengembalikan status code 400
3. Ini adalah **behavior bawaan Flutter testing** untuk memastikan test tidak bergantung pada koneksi internet

### Solusi yang Diterapkan:
```dart
setUpAll(() {
  // Suppress network image errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('NetworkImage') ||
        details.exception.toString().contains('HTTP')) {
      return; // Abaikan error network image
    }
    FlutterError.presentError(details);
  };
});
```

### Alternatif Solusi:
1. **Ganti Image.network() dengan Asset Image** (Recommended):
   ```dart
   // Daripada:
   Image.network("https://...")
   
   // Gunakan:
   Image.asset("assets/images/google_logo.png")
   ```

2. **Gunakan kondisional untuk testing**:
   ```dart
   // Di LoginView
   icon: kDebugMode 
     ? Image.asset("assets/images/google_logo.png")
     : Image.network("https://...")
   ```

3. **Mock Image dengan http package override** (Advanced)

---

## ❓ Kenapa Tidak Bisa Connect ke API?

### Masalah:
API call saat login/register gagal atau tidak ada response

### Penyebab:
**Ini adalah behavior yang DIINGINKAN dalam testing!**

1. **Widget Tests & Integration Tests** dirancang untuk:
   - ✅ Test UI behavior
   - ✅ Test user interaction 
   - ✅ Test state management
   - ❌ **BUKAN** untuk test actual API calls

2. **TestWidgetsFlutterBinding memblokir network**:
   - Semua HTTP request return status 400
   - Tidak ada koneksi ke server real
   - Ini untuk memastikan test berjalan offline dan konsisten

3. **Mock Providers** yang digunakan:
   ```dart
   mockAuthProvider = MockAuthProvider(); // Tidak real network call
   ```

### Solusi Berdasarkan Kebutuhan:

#### A. Test UI Flow (Recommended untuk Widget/Integration Test):
```dart
// Test LOGIN UI flow tanpa actual API
testWidgets('should display login form', (tester) async {
  // Setup mock response
  when(mockAuthProvider.login(any, any))
    .thenAnswer((_) async => Response(statusCode: 200, body: {...}));
  
  // Test UI elements
  expect(find.text('Login'), findsOneWidget);
  
  // Enter credentials
  await tester.enterText(emailField, 'test@example.com');
  
  // Tap login button
  await tester.tap(loginButton);
  
  // Verify loading state
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

#### B. Test dengan Mock HTTP Response:
```dart
// Tambahkan dependencies:
// http_mock_adapter: ^0.6.1

import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dio/dio.dart';

testWidgets('login with mocked API', (tester) async {
  final dio = Dio();
  final dioAdapter = DioAdapter(dio: dio);
  
  // Mock API response
  dioAdapter.onPost(
    '/api/login',
    (server) => server.reply(200, {
      'token': 'fake_token',
      'user': {'id': 1, 'name': 'Test User'}
    }),
  );
  
  // Inject mocked dio ke provider
  final provider = AuthProvider(dio: dio);
  
  // Run test...
});
```

#### C. Test dengan REAL API (End-to-End Test):
```bash
# Gunakan flutter drive untuk E2E testing dengan real device/emulator
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_integration_test.dart

# Atau setup test server/staging environment
# dan gunakan integration test dengan real API endpoint
```

**Setup untuk Real API Testing:**
```dart
// config/test_config.dart
class TestConfig {
  static const bool USE_REAL_API = bool.fromEnvironment('USE_REAL_API');
  static const String API_BASE_URL = USE_REAL_API 
    ? 'https://staging-api.example.com' 
    : 'https://mock-api.example.com';
}

// Jalankan dengan:
// flutter test --dart-define=USE_REAL_API=true
```

---

## ✅ Best Practice Testing

### 1. Widget Tests (Fast, Isolated)
```dart
✅ Test UI rendering
✅ Test user interactions
✅ Test state changes
✅ Use mocks untuk dependencies
❌ Jangan test actual API calls
```

### 2. Integration Tests (Medium Speed)
```dart
✅ Test flow antar screen
✅ Test navigation
✅ Test form validation
✅ Mock API responses
❌ Jangan test dengan production API
```

### 3. E2E Tests (Slow, Real Environment)
```dart
✅ Test dengan real API (staging/test environment)
✅ Test dengan real database
✅ Test full user journey
✅ Run di real device/emulator
```

---

## 🎯 Rekomendasi

### Untuk Project Anda:

1. **Fix Image Error**:
   ```dart
   // Di LoginView, ganti:
   Image.network("https://www.gstatic.com/.../g.webp...")
   
   // Dengan:
   Image.asset("assets/images/google_logo.png")
   ```
   
   Atau download image dan simpan di `assets/images/`

2. **Widget Test**: Focus pada UI & state management
   ```dart
   ✅ Test form validation
   ✅ Test button enable/disable
   ✅ Test loading state
   ✅ Test error messages
   ```

3. **Integration Test**: Focus pada user flow
   ```dart
   ✅ Test complete login flow
   ✅ Test navigation after login
   ✅ Test form submission
   ✅ Mock API dengan expected responses
   ```

4. **Manual Testing**: Test dengan real API
   ```bash
   # Run app di emulator/device dan test manual
   flutter run
   ```

5. **E2E Test** (Optional): Untuk CI/CD pipeline
   ```bash
   # Setup test environment dengan staging API
   flutter drive --target=integration_test/app_test.dart
   ```

---

## 📚 Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [HTTP Mock Adapter](https://pub.dev/packages/http_mock_adapter)

---

## 💡 TL;DR

**Error Image**: Ganti `Image.network()` dengan `Image.asset()` di LoginView

**API Connection**: 
- Widget/Integration test **TIDAK** untuk test actual API
- Gunakan **mock responses** untuk test UI flow
- Gunakan **manual testing** atau **E2E test** untuk test real API
- Test yang ada fokus pada **UI behavior**, bukan API integration
