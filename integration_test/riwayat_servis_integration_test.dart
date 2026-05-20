import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_pelanggan/app/modules/riwayat_servis/views/riwayat_servis_view.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_servis/controllers/riwayat_servis_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK PROVIDER ====================
class MockServiceHistoryProvider extends GetConnect
    implements ServiceHistoryProvider {
  @override
  Future<Response<dynamic>> getServiceHistory(String bookingId) async {
    return Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          '_id': 'hist123',
          'status': 'Selesai',
          'mechanicName': 'Ahmad Fauzi',
          'diagnosis': 'Oli mesin hitam pekat dan kampas rem aus',
          'workDone': 'Ganti Oli Shell Advance & Kampas Rem Depan',
          'endDate': DateTime.now().toIso8601String(),
          'warrantyExpiry':
              DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'notes': 'Disarankan servis rutin setiap 2.000 km.',
          'totalPrice': 150000,
          'workPhotos': null, // 🔥 BUNGKAM: Cegah crash engine gambar lokal
          'spareParts': [
            {'name': 'Oli Shell Advance 10W-40', 'price': 65000, 'quantity': 1},
            {'name': 'Kampas Rem Depan Ori', 'price': 85000, 'quantity': 1},
          ],
        },
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK CONTROLLER ====================
class MockRiwayatServisController extends RiwayatServisController {
  MockRiwayatServisController() : super(provider: MockServiceHistoryProvider());
}

/// Integration Test untuk Riwayat Servis Page
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Riwayat Servis Page Integration Test', () {
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
      // 1. Suntikkan Service History Provider tiruan
      Get.put<ServiceHistoryProvider>(MockServiceHistoryProvider());

      // 2. Siapkan Arguments Palsu ke Rute GetX agar tidak Null Pointer Error saat onInit
      Get.testMode = true;
      Get.routing.args = BookingsModel(
        id: 'book123',
        status: 'Selesai',
        totalPrice: 150000,
      );

      // 3. Daftarkan Controller Utama
      Get.put<RiwayatServisController>(MockRiwayatServisController());
    });

    tearDown(() async {
      try {
        // Tutup otomatis dialog sukses bawaan controller jika masih terbuka
        if (Get.isDialogOpen == true) Get.back();
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
      return const GetMaterialApp(home: RiwayatServisView());
    }

    testWidgets(
      '1. Page loads and displays main mechanics and diagnosis info correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        // Menutup dialog sukses bawaan controller agar tidak menghalangi UI utama
        if (Get.isDialogOpen == true) {
          Get.back();
          await tester.pumpAndSettle();
        }

        expect(find.text('Detail Riwayat Servis'), findsOneWidget);
        expect(find.text('Ahmad Fauzi'), findsOneWidget);
        expect(
          find.text('Oli mesin hitam pekat dan kampas rem aus'),
          findsOneWidget,
        );
      },
    );

    testWidgets('2. Displays spareparts list details and prices accurately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      if (Get.isDialogOpen == true) {
        Get.back();
        await tester.pumpAndSettle();
      }

      // Scroll ke bawah untuk melihat komponen suku cadang
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(find.text('Suku Cadang'), findsOneWidget);
      expect(find.text('Oli Shell Advance 10W-40'), findsOneWidget);
      expect(find.text('Kampas Rem Depan Ori'), findsOneWidget);

      // Memastikan format mata uang total biaya Rp 150.000 tampil pas
      expect(find.text('Rp 150.000'), findsWidgets);
    });

    testWidgets(
      '3. Refresh indicator data reload operations work without crash',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        if (Get.isDialogOpen == true) {
          Get.back();
          await tester.pumpAndSettle();
        }

        final refreshIndicator = find.byType(RefreshIndicator);
        expect(refreshIndicator, findsOneWidget);

        // Tarik layar ke bawah untuk memicu onRefresh
        await tester.fling(
          find.byType(SingleChildScrollView),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        expect(find.text('Detail Riwayat Servis'), findsOneWidget);
      },
    );

    testWidgets(
      '4. Empty state behavior displays correctly when list is clear',
      (WidgetTester tester) async {
        // Bersihkan riwayat servis secara manual untuk memicu layar kosong
        Get.find<RiwayatServisController>().serviceHistory.clear();

        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Belum Ada Riwayat'), findsOneWidget);
        expect(
          find.textContaining('Teknisi belum menambahkan catatan'),
          findsOneWidget,
        );
      },
    );
  });
}
