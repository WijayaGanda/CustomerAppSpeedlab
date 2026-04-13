import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:speedlab_pelanggan/app/modules/register/views/register_view.dart';
import 'package:speedlab_pelanggan/app/modules/register/controllers/register_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';

@GenerateNiceMocks([MockSpec<AuthProvider>()])
import 'register_view_test.mocks.dart';

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
  late RegisterController registerController;

  setUp(() {
    mockAuthProvider = MockAuthProvider();

    // Use fake AuthService for testing
    Get.put<AuthService>(FakeAuthService());

    registerController = RegisterController(provider: mockAuthProvider);
    Get.put(registerController);
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
    return GetMaterialApp(home: const RegisterView());
  }

  group('RegisterView Widget Tests', () {
    testWidgets('should display all required widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify AppBar
      expect(find.text('Register  '), findsOneWidget);

      // Verify CustomHeader
      expect(find.text('Silahkan Mendaftar'), findsOneWidget);
      expect(find.text('Masukkan Data dengan benar'), findsOneWidget);

      // Verify all text fields (name, email, password, phone, address)
      expect(find.byType(TextField), findsNWidgets(5));

      // Verify register button
      expect(find.text('Daftar'), findsOneWidget);
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

    testWidgets('should validate empty fields when register button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap register button without entering data
      final registerButton = find.text('Daftar');
      await tester.tap(registerButton);
      await tester.pump();

      // Verify that controllers are empty
      expect(registerController.nameCtrl.text.isEmpty, true);
      expect(registerController.emailCtrl.text.isEmpty, true);
      expect(registerController.passwordCtrl.text.isEmpty, true);
      expect(registerController.phoneCtrl.text.isEmpty, true);
      expect(registerController.addressCtrl.text.isEmpty, true);
    });

    testWidgets('should enter text in name field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find name field (first TextField)
      final textFields = find.byType(TextField);
      final nameField = textFields.at(0);

      await tester.enterText(nameField, 'John Doe');
      await tester.pump();

      // Verify text was entered
      expect(registerController.nameCtrl.text, 'John Doe');
    });

    testWidgets('should enter text in email field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find email field (second TextField)
      final textFields = find.byType(TextField);
      final emailField = textFields.at(1);

      await tester.enterText(emailField, 'john.doe@example.com');
      await tester.pump();

      // Verify text was entered
      expect(registerController.emailCtrl.text, 'john.doe@example.com');
    });

    testWidgets('should enter text in password field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find password field (third TextField)
      final textFields = find.byType(TextField);
      final passwordField = textFields.at(2);

      await tester.enterText(passwordField, 'securePassword123');
      await tester.pump();

      // Verify text was entered
      expect(registerController.passwordCtrl.text, 'securePassword123');
    });

    testWidgets('should enter text in phone field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find phone field (fourth TextField)
      final textFields = find.byType(TextField);
      final phoneField = textFields.at(3);

      await tester.enterText(phoneField, '081234567890');
      await tester.pump();

      // Verify text was entered
      expect(registerController.phoneCtrl.text, '081234567890');
    });

    testWidgets('should enter text in address field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find address field (fifth TextField)
      final textFields = find.byType(TextField);
      final addressField = textFields.at(4);

      await tester.enterText(addressField, 'Jl. Contoh No. 123');
      await tester.pump();

      // Verify text was entered
      expect(registerController.addressCtrl.text, 'Jl. Contoh No. 123');
    });

    testWidgets('should show loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Set loading state
      registerController.isLoading.value = true;
      await tester.pump();

      // Verify CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify register button is not shown
      expect(find.text('Daftar'), findsNothing);
    });

    testWidgets('should enter all fields with valid data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find all text fields
      final textFields = find.byType(TextField);

      // Enter all fields
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'john@example.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), '081234567890');
      await tester.enterText(textFields.at(4), 'Jl. Contoh No. 123');
      await tester.pump();

      // Verify all fields were filled
      expect(registerController.nameCtrl.text, 'John Doe');
      expect(registerController.emailCtrl.text, 'john@example.com');
      expect(registerController.passwordCtrl.text, 'password123');
      expect(registerController.phoneCtrl.text, '081234567890');
      expect(registerController.addressCtrl.text, 'Jl. Contoh No. 123');
    });

    testWidgets('should scroll when content overflows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
