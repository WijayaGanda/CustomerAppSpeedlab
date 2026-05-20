import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';

import 'package:speedlab_pelanggan/app/modules/edit_profile/views/edit_profile_view.dart';
import 'package:speedlab_pelanggan/app/modules/edit_profile/controllers/edit_profile_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK PROVIDERS ====================
class MockProfileProvider extends GetConnect implements ProfileProvider {
  @override
  Future<Response<dynamic>> updateProfile(Map<String, dynamic> data) async {
    return const Response(
      statusCode: 200,
      body: {'success': true, 'message': 'Profil berhasil diperbarui'},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK SERVICES & CONTROLLERS ====================
// ==================== MOCK SERVICES & CONTROLLERS ====================
class MockAuthService extends GetxService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// 🔥 PERBAIKAN: Ganti nama dari 'user' menjadi 'users' (pake s) agar match dengan controller asli!
class MockProfileController extends GetxController
    implements ProfileController {
  @override
  final users = Rx<UserModel>(
    UserModel(id: '1', name: 'Budi Santoso', email: 'budi@example.com'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Data Objek Tiruan untuk Arguments dan State Management
class _DummyUser {
  String? name = 'Siti Rahma';
  String? email = 'siti@example.com';
  String? phone = '081234567890';
  String? address = 'Jl. Merdeka No. 123';
}

/// Integration Test untuk Edit Profile Page
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit Profile Page Integration Test', () {
    setUpAll(() {
      HttpOverrides.global = MyHttpOverrides();

      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('NetworkImage') ||
            details.exception.toString().contains('HTTP') ||
            details.exception.toString().contains('SocketException') ||
            details.exception.toString().contains('Image')) {
          return;
        }
        FlutterError.presentError(details);
      };
    });

    setUp(() {
      // 1. Suntikkan Dependensi Layanan Global Paling Awal
      Get.put<ProfileProvider>(MockProfileProvider());
      Get.put<AuthService>(MockAuthService());

      // 🔥 FIX: Memanggil konstruktor MockProfileController() dengan benar
      Get.put<ProfileController>(MockProfileController());

      // 2. Suntikkan Arguments Palsu ke Rute GetX agar Inisialisasi late Controller Sukses
      Get.testMode = true;
      Get.routing.args = _DummyUser();

      // 3. Daftarkan EditProfileController Utama
      Get.put<EditProfileController>(EditProfileController());
    });

    tearDown(() async {
      try {
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 100));
      Get.reset();
      Get.routing.args = null;
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    Widget createTestableWidget() {
      return GetMaterialApp(
        home: const EditProfileView(),
        getPages: [
          GetPage(
            name: '/dashboard',
            page: () => const Scaffold(body: Text('Halaman Dashboard')),
          ),
        ],
      );
    }

    testWidgets('1. Edit Profile page loads with pre-filled form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Ubah Data Profil'), findsOneWidget);
    });

    testWidgets('2. Form fields are pre-filled with existing user data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Siti Rahma'), findsOneWidget);
      expect(find.text('siti@example.com'), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);
      expect(find.text('Jl. Merdeka No. 123'), findsOneWidget);
    });

    testWidgets('3. Can modify all profile fields successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      await tester.enterText(textFields.at(0), '');
      await tester.pumpAndSettle();
      await tester.enterText(textFields.at(0), 'Siti Rahmawati');

      await tester.enterText(textFields.at(1), '');
      await tester.pumpAndSettle();
      await tester.enterText(textFields.at(1), 'rahma@example.com');

      await tester.enterText(textFields.at(2), '');
      await tester.pumpAndSettle();
      await tester.enterText(textFields.at(2), '081298765432');

      await tester.enterText(textFields.at(3), '');
      await tester.pumpAndSettle();
      await tester.enterText(textFields.at(3), 'Jl. Sudirman No. 456, Bandung');

      await tester.pumpAndSettle();

      expect(find.text('Siti Rahmawati'), findsOneWidget);
      expect(find.text('rahma@example.com'), findsOneWidget);
    });

    testWidgets('4. Can scroll through form to see save button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });

    testWidgets('5. All form labels are visible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Nama'), findsWidgets);
      expect(find.textContaining('Email'), findsWidgets);
      expect(find.textContaining('No. Telepon'), findsWidgets);
      expect(find.textContaining('Alamat'), findsWidgets);
    });

    testWidgets('6. Edit icon displays in header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsWidgets);
    });

    testWidgets('7. Save profile changes redirects safely to dashboard', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      final saveButton = find.text('Simpan Perubahan');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Halaman Dashboard'), findsOneWidget);
    });

    testWidgets('8. Background scaffolding renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
