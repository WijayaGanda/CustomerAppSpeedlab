import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/profile_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/edit_profile/controllers/edit_profile_controller.dart';
import 'package:speedlab_pelanggan/app/modules/edit_profile/views/edit_profile_view.dart';

// ==================== Mock Providers & Services ====================
class MockProfileProvider extends GetConnect implements ProfileProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Edit Profile Controller ====================
class MockEditProfileController extends GetxController
    implements EditProfileController {
  @override
  final isLoading = false.obs;

  @override
  late TextEditingController nameCtrl;
  @override
  late TextEditingController emailCtrl;
  @override
  late TextEditingController phoneCtrl;
  @override
  late TextEditingController addressCtrl;

  @override
  ProfileProvider get provider => MockProfileProvider();

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController(text: 'Budi Santoso');
    emailCtrl = TextEditingController(text: 'budi@example.com');
    phoneCtrl = TextEditingController(text: '+62 812-3456-7890');
    addressCtrl = TextEditingController(text: 'Jl. Merdeka No. 123');
  }

  @override
  Future<void> updateProfile() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockEditProfileController mockEditProfileController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Buka akses internet dan matikan Google Fonts fetching
    HttpOverrides.global = null;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    Get.put<AuthService>(MockAuthService());

    mockEditProfileController = MockEditProfileController();
    mockEditProfileController.onInit();
    Get.put<EditProfileController>(mockEditProfileController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderEditProfileView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(const GetMaterialApp(home: EditProfileView()));
      await tester.pump();
    });
  }

  group('EditProfileView Widget Tests', () {
    testWidgets('1. Memastikan Halaman di render', (WidgetTester tester) async {
      await renderEditProfileView(tester);
      expect(find.byType(EditProfileView), findsOneWidget);
    });

    testWidgets('2. Appbar menampilkan judul yang benar', (
      WidgetTester tester,
    ) async {
      await renderEditProfileView(tester);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);
    });

    testWidgets('3. CustomHeader ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderEditProfileView(tester);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Ubah Data Profil'), findsOneWidget);
      expect(find.text('Perbarui informasi profil Anda'), findsOneWidget);
    });

    testWidgets('4. Form fields ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderEditProfileView(tester);
      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('No. Telepon'), findsOneWidget);
      expect(find.text('Alamat'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('5. Form icons ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderEditProfileView(tester);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.location_city), findsOneWidget);
    });

    testWidgets('6. Tombol Simpan ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderEditProfileView(tester);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });
  });
}
