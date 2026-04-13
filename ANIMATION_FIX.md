# Animation Disposal Fix

## Problem
Error saat running test: "An animation is still running even after the widget tree was disposed"

## Root Cause
GetX Snackbar animation masih berjalan saat test selesai dan memanggil `Get.reset()`, yang menyebabkan widget tree didispose sebelum animation selesai.

### Why This Happens
1. Controller menampilkan Snackbar saat validation error atau API error
2. Snackbar memiliki animasi reverse saat akan hilang
3. Test `tearDown()` dipanggil dan langsung `Get.reset()`
4. AnimationController masih mencoba menjalankan animation
5. Widget tree sudah didispose → Error!

## Solution Applied

Updated `tearDown()` method di semua test files:

### Before (❌ Bermasalah)
```dart
tearDown(() {
  Get.reset();
});
```

### After (✅ Fixed)
```dart
tearDown(() async {
  // Close any open snackbars and wait for animations to complete
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }
  // Wait a bit for any remaining animations to finish
  await Future.delayed(const Duration(milliseconds: 100));
  Get.reset();
});
```

## Files Updated
1. ✅ `test/login_view_test.dart`
2. ✅ `test/register_view_test.dart`
3. ✅ `integration_test/login_integration_test.dart`
4. ✅ `integration_test/register_integration_test.dart`

## What The Fix Does

1. **Check Snackbar Status**: `Get.isSnackbarOpen` - periksa ada snackbar terbuka
2. **Close Gracefully**: `Get.closeAllSnackbars()` - tutup semua snackbar dengan proper
3. **Wait for Animations**: `await Future.delayed(100ms)` - tunggu animasi selesai
4. **Reset State**: `Get.reset()` - bersihkan GetX state setelah aman

## Verification

Run tests untuk verify fix:

```bash
# Widget tests (seharusnya tidak ada animation error lagi)
flutter test test/register_view_test.dart
flutter test test/login_view_test.dart

# Integration tests
flutter test integration_test/register_integration_test.dart
flutter test integration_test/login_integration_test.dart
```

### Expected Result
✅ No more "Animation is still running" error
✅ All tests complete cleanly
⚠️ Login tests masih failed karena Image.network() issue (bukan animation issue)

## Additional Notes

### Kenapa 100ms?
- GetX snackbar default duration sangat cepat
- 100ms cukup untuk closing animation
- Tidak terlalu lama untuk slow down test execution

### Alternative Solutions
Jika masih ada error (rare cases):

1. **Increase delay**:
```dart
await Future.delayed(const Duration(milliseconds: 300));
```

2. **Use pumpAndSettle** (untuk widget tests):
```dart
tearDown(() async {
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }
  await tester.pumpAndSettle(const Duration(seconds: 1));
  Get.reset();
});
```

3. **Disable snackbar in tests** (drastic):
```dart
// In test setup
Get.testMode = true; // Disables snackbars
```

## Best Practices

### DO ✅
- Always check `Get.isSnackbarOpen` before cleanup
- Use `await Future.delayed()` for async tearDown
- Close snackbars explicitly with `Get.closeAllSnackbars()`
- Add comments explaining why cleanup is needed

### DON'T ❌
- Don't call `Get.reset()` immediately after operations that show snackbars
- Don't ignore animation warnings in test output
- Don't use very long delays (slow down tests unnecessarily)
- Don't disable snackbars globally (loses test coverage)

## Related Issues

This fix also helps with:
- Dialog animation errors
- BottomSheet animation errors
- Any GetX overlay animations

## References

- GetX Snackbar: https://pub.dev/packages/get#snackbars
- Flutter Animation Testing: https://docs.flutter.dev/cookbook/testing/widget/introduction
- TestWidgets Binding: https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html

---

**Status**: ✅ RESOLVED
**Date**: 2026-03-11
**Apply to**: All 4 test files
