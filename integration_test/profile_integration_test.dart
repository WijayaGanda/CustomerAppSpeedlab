import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_pelanggan/app/modules/profile/views/profile_view.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK PROVIDERS & SERVICES ====================
class MockProfileProvider extends GetConnect implements ProfileProvider {
  @override
  Future<Response<dynamic>> fetchProfile() async {
    return Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          'id': '1',
          'name': 'Budi Santoso',
          'email': 'budi@example.com',
          'phone': '+62 812-3456-7890',
          'address': 'Jl. Merdeka No. 123, Jakarta Pusat, DKI Jakarta',
          'avatar': null,
        },
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  @override
  void logout() {
    debugPrint("⚡ Bypassed AuthService Logout");
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK CONTROLLER BYPASS ====================
class MockProfileController extends ProfileController {
  MockProfileController() : super(provider: MockProfileProvider(), authservice: MockAuthService());

  // 🔥 BYPASS LOGOUT FIREBASE AGAR TIDAK CRASH DI FLUTTER TEST
  @override
  void logout() {
    debugPrint("⚡ Bypassed Firebase Token Unregister & Redirected safely");
    authservice.logout();
    Get.offAllNamed('/login'); // Lempar langsung ke rute dummy login
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Page Integration Test', () {
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
      // 1. Suntikkan dependensi tiruan global
      Get.put<ProfileProvider>(MockProfileProvider());
      Get.put<AuthService>(MockAuthService());

      // 2. Suntikkan MockProfileController yang memotong alur Firebase
      Get.put<ProfileController>(MockProfileController());
    });

    tearDown(() async {
      try {
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 100));
      Get.reset();
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    Widget createTestableWidget() {
      return GetMaterialApp(
        home: const ProfileView(),
        // Daftar rute dummy untuk memuaskan perpindahan halaman pasca interaksi klik
        getPages: [
          GetPage(
            name: '/edit-profile',
            page: () => const Scaffold(body: Text('Halaman Edit Profil')),
          ),
          GetPage(
            name: '/security',
            page: () => const Scaffold(body: Text('Halaman Keamanan')),
          ),
          GetPage(
            name: '/login',
            page: () => const Scaffold(body: Text('Halaman Login')),
          ),
        ],
      );
    }

    testWidgets(
      '1. Profile page loads and displays user information correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Profil Saya'), findsOneWidget);
        expect(find.text('Budi Santoso'), findsOneWidget);
        expect(find.text('budi@example.com'), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
      },
    );

    testWidgets(
      '2. Profile page displays user contact and address information',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -100));
          await tester.pumpAndSettle();
        }

        expect(find.text('No. Telepon'), findsOneWidget);
        expect(find.text('+62 812-3456-7890'), findsOneWidget);
        expect(find.text('Alamat'), findsOneWidget);
        expect(
          find.text('Jl. Merdeka No. 123, Jakarta Pusat, DKI Jakarta'),
          findsOneWidget,
        );
      },
    );

    testWidgets('3. Menu items display with correct titles and descriptions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
        await tester.pumpAndSettle();
      }

      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Perbarui informasi pribadi Anda'), findsOneWidget);
      expect(find.text('Keamanan'), findsOneWidget);
      expect(find.text('Ubah kata sandi dan proteksi akun'), findsOneWidget);
    });

    testWidgets('4. Tap Edit Profil navigates to edit profile page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
        await tester.pumpAndSettle();
      }

      final editButton = find.text('Edit Profil');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.text('Halaman Edit Profil'), findsOneWidget);
    });

    testWidgets('5. Tap Keamanan navigates to security page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -250));
        await tester.pumpAndSettle();
      }

      final securityButton = find.text('Keamanan');
      await tester.tap(securityButton);
      await tester.pumpAndSettle();

      expect(find.text('Halaman Keamanan'), findsOneWidget);
    });

    testWidgets('6. Pull down to refresh triggers data reload', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Profil Saya'), findsOneWidget);
    });

    testWidgets(
      '7. Interactive Flow: Logout button displays confirmation dialog and exits',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -400));
          await tester.pumpAndSettle();
        }

        final logoutButton = find.text('Keluar Akun');
        expect(logoutButton, findsOneWidget);
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        // Memastikan pop-up ConfirmationDialog milik Anda terbuka sempurna
        expect(find.text('Konfirmasi Logout'), findsOneWidget);

        final confirmExitButton = find.text('Ya, Keluar');
        expect(confirmExitButton, findsOneWidget);

        await tester.tap(confirmExitButton);
        await tester.pumpAndSettle();

        // Sukses melempar alur keluar akun ke halaman login dummy!
        expect(find.text('Halaman Login'), findsOneWidget);
      },
    );
  });
}
