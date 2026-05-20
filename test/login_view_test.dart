import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart'; // Import package baru

// Sesuaikan path ini dengan struktur folder Anda
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/modules/login/controllers/login_controller.dart';
import 'package:speedlab_pelanggan/app/modules/login/views/login_view.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_textfield.dart';

class MockAuthProvider implements AuthProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLoginController extends LoginController {
  MockLoginController() : super(provider: MockAuthProvider());

  bool isLoginCalled = false;
  bool isGoogleLoginCalled = false;

  @override
  void login() {
    isLoginCalled = true;
  }

  @override
  void loginWithGoogle() {
    isGoogleLoginCalled = true;
  }
}

void main() {
  late MockLoginController mockController;

  setUp(() {
    mockController = MockLoginController();
    Get.put<LoginController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestableWidget() {
    return GetMaterialApp(home: const LoginView());
  }

  group('LoginView Widget Tests', () {
    testWidgets(
      'Pastikan semua elemen UI LoginView muncul di layar (Smoke Test)',
      (WidgetTester tester) async {
        // BUNGKUS pumpWidget DENGAN mockNetworkImagesFor
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createTestableWidget());

          expect(find.text('Login '), findsOneWidget);
          expect(find.text('Selamat Datang'), findsOneWidget);
          expect(find.text('Silakan masuk untuk melanjutkan'), findsOneWidget);
          expect(find.text('Masukkan email anda'), findsOneWidget);
          expect(find.text('Masukkan password anda'), findsOneWidget);
          expect(find.text('Lupa Password?'), findsOneWidget);
          expect(find.text('Masuk'), findsOneWidget);
          expect(find.text('Belum Punya Akun?'), findsOneWidget);
          expect(find.text('Daftar'), findsOneWidget);
          expect(find.byType(CustomTextField), findsNWidgets(2));
        });
      },
    );

    testWidgets(
      'Fungsi toggle visibility password berjalan saat icon ditekan',
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createTestableWidget());

          bool initialState = mockController.isVisible.value;
          final visibilityButton = find.byType(IconButton).first;

          await tester.tap(visibilityButton);
          await tester.pump();

          expect(mockController.isVisible.value, !initialState);
        });
      },
    );

    testWidgets('Fungsi login terpanggil saat tombol Masuk diklik', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestableWidget());

        final btnMasuk = find.text('Masuk');

        await tester.tap(btnMasuk);
        await tester.pump();

        expect(mockController.isLoginCalled, isTrue);
      });
    });

    testWidgets(
      'Menampilkan CircularProgressIndicator saat isLoading bernilai true',
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createTestableWidget());

          mockController.isLoading.value = true;
          await tester.pump();

          expect(find.text('Masuk'), findsNothing);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });
      },
    );
  });
}
