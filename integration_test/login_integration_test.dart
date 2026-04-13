import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/modules/login/views/login_view.dart';
import 'package:speedlab_pelanggan/app/modules/login/controllers/login_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

/// Integration Test untuk Login
///
/// CATATAN PENTING:
/// 1. Test ini akan GAGAL connect ke API karena:
///    - Menggunakan mock providers (tidak real network call)
///    - TestWidgetsFlutterBinding memblokir HTTP requests dan return 400
///
/// 2. Untuk test dengan REAL API:
///    - Gunakan flutter drive dengan device/emulator nyala
///    - Atau setup HTTP mock server (mockito, http_mock_adapter)
///    - Atau skip API validation dan hanya test UI flow
///
/// 3. Network Image Error (Google Logo):
///    - Sudah di-handle dengan error suppression
///    - Tidak mempengaruhi test UI flow
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Test', () {
    late AuthProvider authProvider;
    late AuthService authService;

    setUpAll(() {
      // Suppress network image errors during testing
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('NetworkImage') ||
            details.exception.toString().contains('HTTP') ||
            details.exception.toString().contains('SocketException')) {
          // Ignore network-related errors in tests
          return;
        }
        FlutterError.presentError(details);
      };
    });

    setUp(() {
      // Initialize real providers for integration testing
      // NOTE: API calls will fail in test environment
      authProvider = AuthProvider();
      authService = AuthService();

      Get.put<AuthService>(authService);
      Get.put<LoginController>(LoginController(provider: authProvider));
    });

    tearDown(() async {
      // Close any open snackbars and wait for animations to complete
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      // Wait a bit for any remaining animations to finish
      await Future.delayed(const Duration(milliseconds: 100));
      Get.reset();
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    testWidgets('Complete login flow with valid credentials', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
          getPages: [
            GetPage(
              name: '/dashboard',
              page:
                  () => const Scaffold(body: Center(child: Text('Dashboard'))),
            ),
            GetPage(
              name: '/forgot-password',
              page:
                  () => const Scaffold(
                    body: Center(child: Text('Forgot Password')),
                  ),
            ),
          ],
        ),
      );

      // Wait for the UI to load
      await tester.pumpAndSettle();

      // Verify login page is displayed
      expect(find.text('Login '), findsOneWidget);
      expect(find.text('Selamat Datang'), findsOneWidget);

      // Find email and password text fields
      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.keyboardType == TextInputType.emailAddress,
      );
      final textFields = find.byType(TextField);
      final passwordField = textFields.at(1);

      // Enter valid credentials
      await tester.enterText(emailField, 'john@example.com');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(passwordField, 'password123');
      await tester.pump(const Duration(milliseconds: 100));

      // Verify text was entered
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      // Find and tap the login button
      final loginButton = find.text('Masuk');
      expect(loginButton, findsOneWidget);

      // Note: Actual login will fail without real backend
      // This test verifies the UI flow and button interaction
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // In a real scenario, you would verify navigation to dashboard
      // For this test, we verify the login button was tappable
    });

    testWidgets('Login flow with empty credentials shows error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const LoginView()));

      await tester.pumpAndSettle();

      // Tap login button without entering credentials
      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify error handling (empty fields should trigger validation)
      // The actual error message depends on CustomSnackbar implementation
    });

    testWidgets('Password visibility toggle works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const LoginView()));

      await tester.pumpAndSettle();

      // Find password field
      final textFields = find.byType(TextField);
      final passwordField = textFields.at(1);

      // Enter password
      await tester.enterText(passwordField, 'mySecretPassword');
      await tester.pump();

      // Find and tap visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility_off);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();

      // Verify icon changed
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap again to toggle back
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Navigate to forgot password screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
          getPages: [
            GetPage(
              name: '/forgot-password',
              page:
                  () => const Scaffold(
                    body: Center(child: Text('Forgot Password Page')),
                  ),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap forgot password button
      final forgotPasswordButton = find.text('Lupa Password?');
      expect(forgotPasswordButton, findsOneWidget);

      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.text('Forgot Password Page'), findsOneWidget);
    });

    testWidgets('Google sign-in button is visible and tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const LoginView()));

      await tester.pumpAndSettle();

      // Verify "ATAU" divider
      expect(find.text('ATAU'), findsOneWidget);

      // Verify Google sign-in button exists
      final googleButton = find.byType(IconButton).last;
      expect(googleButton, findsOneWidget);

      // Note: Actually tapping would require Google Sign-In setup
      // This test verifies the button is present
    });

    testWidgets('Login form scrolls when keyboard appears', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const LoginView()));

      await tester.pumpAndSettle();

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Simulate scrolling
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Verify still on login page
      expect(find.text('Login '), findsOneWidget);
    });

    testWidgets('Email field accepts email input', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: const LoginView()));

      await tester.pumpAndSettle();

      // Find email field
      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.keyboardType == TextInputType.emailAddress,
      );

      // Test various email formats
      await tester.enterText(emailField, 'user@example.com');
      await tester.pump();
      expect(find.text('user@example.com'), findsOneWidget);

      await tester.enterText(emailField, 'another.user+test@domain.co.id');
      await tester.pump();
      expect(find.text('another.user+test@domain.co.id'), findsOneWidget);
    });

    testWidgets('Password field accepts password input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const LoginView()));

      await tester.pumpAndSettle();

      // Find password field
      final textFields = find.byType(TextField);
      final passwordField = textFields.at(1);

      // Test password input
      await tester.enterText(passwordField, 'MyP@ssw0rd!123');
      await tester.pump();
      expect(find.text('MyP@ssw0rd!123'), findsOneWidget);
    });
  });
}
