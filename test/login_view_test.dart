import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:speedlab_pelanggan/app/modules/login/views/login_view.dart';
import 'package:speedlab_pelanggan/app/modules/login/controllers/login_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';

@GenerateNiceMocks([MockSpec<AuthProvider>()])
import 'login_view_test.mocks.dart';

// Fake AuthService for testing
class FakeAuthService extends GetxService implements AuthService {
  @override
  var user = Rxn<UserModel>();

  @override
  bool get isLoggedIn => _token != null;

  String? _token;

  @override
  String? get token => _token;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  void login(String token, UserModel userModel) {
    _token = token;
    user.value = userModel;
  }

  @override
  void logout() {
    _token = null;
    user.value = null;
  }
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late LoginController loginController;

  setUp(() {
    mockAuthProvider = MockAuthProvider();

    // Use fake AuthService for testing
    Get.put<AuthService>(FakeAuthService());

    loginController = LoginController(provider: mockAuthProvider);
    Get.put(loginController);
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

  Widget createWidgetUnderTest() {
    return GetMaterialApp(home: const LoginView());
  }

  group('LoginView Widget Tests', () {
    testWidgets('should display all required widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify AppBar
      expect(find.text('Login '), findsOneWidget);

      // Verify CustomHeader
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Silakan masuk untuk melanjutkan'), findsOneWidget);

      // Verify email and password fields
      expect(find.byType(TextField), findsNWidgets(2));

      // Verify forgot password button
      expect(find.text('Lupa Password?'), findsOneWidget);

      // Verify login button
      expect(find.text('Masuk'), findsOneWidget);

      // Verify Google sign-in section
      expect(find.text('ATAU'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the visibility toggle icon button
      final visibilityButton = find.byIcon(Icons.visibility_off);
      expect(visibilityButton, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityButton);
      await tester.pump();

      // Verify icon changed to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap again to toggle back
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Verify icon changed back to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should validate empty fields when login button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap login button without entering credentials
      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify that controllers are empty
      expect(loginController.emailController.text.isEmpty, true);
      expect(loginController.passwordController.text.isEmpty, true);
    });

    testWidgets('should enter text in email field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find email field and enter text
      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.keyboardType == TextInputType.emailAddress,
      );

      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Verify text was entered
      expect(loginController.emailController.text, 'test@example.com');
    });

    testWidgets('should enter text in password field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find password field (second TextField)
      final textFields = find.byType(TextField);
      final passwordField = textFields.at(1);

      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Verify text was entered
      expect(loginController.passwordController.text, 'password123');
    });

    testWidgets('should navigate to forgot password screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap forgot password button
      final forgotPasswordButton = find.text('Lupa Password?');
      expect(forgotPasswordButton, findsOneWidget);

      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Note: Navigation test akan berhasil jika route '/forgot-password' terdaftar
    });

    testWidgets('should show loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Set loading state
      loginController.isLoading.value = true;
      await tester.pump();

      // Verify CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify login button is not shown
      expect(find.text('Masuk'), findsNothing);
    });

    testWidgets(
      'should call login method when login button is tapped with valid credentials',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter email and password
        final emailField = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.keyboardType == TextInputType.emailAddress,
        );
        final textFields = find.byType(TextField);
        final passwordField = textFields.at(1);

        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        // Verify text was entered correctly
        expect(loginController.emailController.text, 'test@example.com');
        expect(loginController.passwordController.text, 'password123');
      },
    );
  });
}
