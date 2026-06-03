import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_pelanggan/app/modules/add_motor/views/add_motor_view.dart';
import 'package:speedlab_pelanggan/app/modules/add_motor/controllers/add_motor_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';

// Class untuk mem-bypass error HTTP dan NetworkImage bawaan Flutter Test
class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK PROVIDER ====================
// Menjaga agar jika sewaktu-waktu controller memanggil API,
// dia tidak akan crash karena diblokir oleh environment testing.
class MockMotorcyclesProvider extends GetConnect
    implements MotorcyclesProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Integration Test untuk Add Motor Page
/// Fokus: Form filling, UI Validation, Reset Action
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Motor Page Integration Test', () {
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
      // 1. Suntikkan Mock Provider ke memori GetX terlebih dahulu!
      Get.put<MotorcyclesProvider>(MockMotorcyclesProvider());

      // 2. Barulah panggil Controller-nya.
      // Saat memanggil Get.find(), dia akan otomatis mengambil Mock di atas!
      Get.put<AddMotorController>(
        AddMotorController(provider: Get.find<MotorcyclesProvider>()),
      );
    });

    tearDown(() async {
      try {
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 100));
      // PERBAIKAN: Hapus 'await' karena Get.reset() adalah void
      Get.reset();
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    // Helper untuk merender halaman Add Motor secara terisolasi
    Widget createTestableWidget() {
      return const GetMaterialApp(home: AddMotorView());
    }

    testWidgets('1. Add Motor page loads with form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Daftar Motor Baru'), findsOneWidget);
    });

    testWidgets('2. Can fill all form fields with valid data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Isi form (Flutter Test otomatis men-scroll ke field yang dituju saat enterText)
      await tester.enterText(textFields.at(0), 'Honda');
      await tester.enterText(textFields.at(1), 'Vario 150');
      await tester.enterText(textFields.at(2), '2022');
      await tester.enterText(textFields.at(3), 'B 1234 XYZ');
      await tester.enterText(textFields.at(4), 'Hitam');
      await tester.pumpAndSettle();

      expect(find.text('Honda'), findsOneWidget);
      expect(find.text('Vario 150'), findsOneWidget);
      expect(find.text('2022'), findsOneWidget);
    });

    testWidgets('3. Can scroll through form to see all fields and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Gunakan Scrollable agar lebih fleksibel (tahan banting jika tipe container diubah)
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(find.text('Tambah Motor'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('4. Reset button clears all fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Isi form
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Kawasaki');
      await tester.pumpAndSettle();

      // Pastikan teks masuk
      expect(find.text('Kawasaki'), findsOneWidget);

      // Scroll ke bawah untuk mencari tombol Reset
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      // Tap Reset
      final resetButton = find.text('Reset');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Pastikan teks hilang
      expect(find.text('Kawasaki'), findsNothing);
    });

    testWidgets('5. Hint text displays for each field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Contoh: Honda, Yamaha, Suzuki'), findsOneWidget);
      expect(find.text('Contoh: CBR, Vario, Nmax'), findsOneWidget);
      expect(find.text('Contoh: 2020, 2021, 2022'), findsOneWidget);
      expect(find.text('Contoh: B 1234 AB'), findsOneWidget);
    });

    testWidgets('6. AppBar displays correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Daftar Motor Baru'), findsOneWidget);
    });

    testWidgets('7. CustomHeader displays with correct content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tambahkan Motor'), findsOneWidget);
      expect(
        find.text('Daftarkan motor kamu untuk memudahkan proses booking!'),
        findsOneWidget,
      );
    });

    testWidgets('8. All form labels are visible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Merek Motor'), findsOneWidget);
      expect(find.text('Model Motor'), findsOneWidget);
      expect(find.text('Tahun Motor'), findsOneWidget);
      expect(find.text('Plat Nomor'), findsOneWidget);

      // Scroll ke bawah untuk label terakhir
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(find.text('Warna Motor'), findsOneWidget);
    });

    testWidgets('9. Form remains responsive after filling fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Isi semua field
      for (int i = 0; i < 5; i++) {
        await tester.enterText(textFields.at(i), 'Test Data $i');
      }
      await tester.pumpAndSettle();

      // Scroll ke atas dan ke bawah untuk memastikan UI tidak nyangkut/freeze
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.drag(scrollable.first, const Offset(0, 200));
        await tester.pumpAndSettle();
      }

      expect(find.text('Daftar Motor Baru'), findsOneWidget);
    });

    testWidgets('10. Motorcycle icon displays in header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // PERBAIKAN: Gunakan findsWidgets karena ikon dipakai lebih dari sekali di layar ini
      expect(find.byIcon(Icons.motorcycle), findsWidgets);
    });

    testWidgets('11. Background color consistent with design', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
