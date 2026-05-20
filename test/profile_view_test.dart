import 'dart:io'; // 🌟 Wajib ditambah untuk HttpOverrides
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/profile/controllers/profile_controller.dart';
import 'package:speedlab_pelanggan/app/modules/profile/views/profile_view.dart';

// ==================== Mock Providers & Services ====================
class MockProfileProvider extends GetConnect implements ProfileProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Controller ====================
class MockProfileController extends GetxController
    implements ProfileController {
  @override
  final users =
      UserModel(
        id: '1',
        name: 'Budi Santoso',
        email: 'budi@example.com',
        phone: '+62 812-3456-7890',
        address: 'Jl. Merdeka No. 123, Jakarta Pusat, DKI Jakarta',
        // Avatar ini butuh akses internet saat tes dijalankan
        avatar:
            'https://ui-avatars.com/api/?name=Budi+Santoso&background=4CAF50&color=fff',
      ).obs;

  @override
  final isLoading = false.obs;

  @override
  ProfileProvider get provider => MockProfileProvider();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
  }

  @override
  void editProfile() {}

  @override
  void logout() {}

  @override
  Future<void> fetchProfile() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockProfileController mockProfileController;

  setUpAll(() {
    // 🔥 INI KUNCINYA: Buka gerbang internet agar avatar bisa di-download oleh NetworkImage
    HttpOverrides.global = null;

    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    Get.put<AuthService>(MockAuthService());

    mockProfileController = MockProfileController();
    mockProfileController.onInit();
    Get.put<ProfileController>(mockProfileController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderProfileView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Kita gunakan runAsync + pump biasa agar tes tidak timeout menunggu gambar di-load
    await tester.runAsync(() async {
      await tester.pumpWidget(const GetMaterialApp(home: ProfileView()));
      await tester.pump();
    });
  }

  group('Profile View Widget Test', () {
    testWidgets('1. Memastikan Halaman di render', (WidgetTester tester) async {
      await renderProfileView(tester);
      expect(find.byType(ProfileView), findsOneWidget);
    });

    testWidgets('2. Appbar menampilkan judul yang benar', (
      WidgetTester tester,
    ) async {
      await renderProfileView(tester);
      expect(find.text('Profil Saya'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('3. Avatar pengguna ditampilkan', (WidgetTester tester) async {
      await renderProfileView(tester);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('4. Informasi dasar pengguna ditampilkan', (
      WidgetTester tester,
    ) async {
      await renderProfileView(tester);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('budi@example.com'), findsOneWidget);
    });

    testWidgets('5. Informasi detail pengguna ditampilkan', (
      WidgetTester tester,
    ) async {
      await renderProfileView(tester);
      expect(find.text('No. Telepon'), findsOneWidget);
      expect(find.text('+62 812-3456-7890'), findsOneWidget);
      expect(find.text('Alamat'), findsOneWidget);
      expect(
        find.text('Jl. Merdeka No. 123, Jakarta Pusat, DKI Jakarta'),
        findsOneWidget,
      );
    });

    testWidgets('6. Daftar menu ditampilkan', (WidgetTester tester) async {
      await renderProfileView(tester);
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Keamanan'), findsOneWidget);
      expect(find.text('Keluar Akun'), findsOneWidget);
    });

    testWidgets('7. Ikon menu ditampilkan', (WidgetTester tester) async {
      await renderProfileView(tester);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.security_rounded), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });
  });
}
