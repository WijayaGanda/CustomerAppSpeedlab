import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/warranty_model.dart';

import 'package:speedlab_pelanggan/app/modules/klaim_garansi/views/klaim_garansi_view.dart';
import 'package:speedlab_pelanggan/app/modules/klaim_garansi/controllers/klaim_garansi_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';
import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK PROVIDERS ====================
class MockServiceHistoryProvider extends GetConnect
    implements ServiceHistoryProvider {
  @override
  Future<Response<dynamic>> getServiceHistory(String bookingId) async {
    return Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          '_id': 'hist_999',
          'status': 'Selesai',
          'warrantyExpiry':
              DateTime.now()
                  .add(const Duration(days: 15))
                  .toIso8601String(), // Garansi masih berlaku
          'motorcycleId': {
            '_id': 'motor_777',
            'brand': 'Honda',
            'model': 'Vario 150',
            'licensePlate': 'B 1234 XYZ',
          },
        },
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWarrantyClaimProvider extends GetConnect
    implements WarrantyClaimProvider {
  @override
  Future<Response<dynamic>> getMyWarrantyClaims() async {
    // Awalnya kosong agar user bisa mengisi form klaim baru
    return const Response(statusCode: 200, body: {'success': true, 'data': []});
  }

  @override
  Future<Response<dynamic>> submitWarrantyClaim(
    Map<String, dynamic> data,
  ) async {
    return const Response(
      statusCode: 200,
      body: {'success': true, 'message': 'Klaim diajukan'},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK CONTROLLER ====================
class MockKlaimGaransiController extends KlaimGaransiController {
  MockKlaimGaransiController()
    : super(
        provider: MockServiceHistoryProvider(),
        warrantyProvider: MockWarrantyClaimProvider(),
      );
}

/// Integration Test untuk Klaim Garansi Page
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Klaim Garansi Page Integration Test', () {
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
      // 1. Suntikkan providers tiruan
      Get.put<ServiceHistoryProvider>(MockServiceHistoryProvider());
      Get.put<WarrantyClaimProvider>(MockWarrantyClaimProvider());

      // 2. Suapkan Get.arguments agar onInit() tidak null pointer crash
      Get.testMode = true;
      Get.routing.args = BookingsModel(id: 'book_999');

      // 3. Daftarkan controller utama
      Get.put<KlaimGaransiController>(MockKlaimGaransiController());
    });

    tearDown(() async {
      try {
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
      return const GetMaterialApp(home: KlaimGaransiView());
    }

    testWidgets(
      '1. Page loads, displays motorcycle info and form fields properly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Klaim Garansi'), findsOneWidget);
        expect(find.text('Kendaraan Anda:'), findsOneWidget);
        expect(
          find.text('B 1234 XYZ'),
          findsOneWidget,
        ); // Memastikan plat nomor ter-render
      },
    );

    testWidgets(
      '2. Fill complaint field and submit warranty claim successfully',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        // Cari kolom keluhan berdasarkan tipe TextField
        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        // Ketik teks keluhan multi-baris ke form
        await tester.enterText(
          textField.first,
          'CVT gredek kembali setelah 2 hari\nSuara kasar di bagian mesin kanan.',
        );
        await tester.pumpAndSettle();

        // Gulir halaman sedikit ke bawah agar tombol kirim terlihat sempurna
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -200));
          await tester.pumpAndSettle();
        }

        // Cari dan klik tombol kirim klaim garansi
        final submitButton = find.text('Ajukan Klaim Garansi');
        expect(submitButton, findsOneWidget);

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Memastikan CustomModal sukses dialog muncul pasca submit
        expect(find.text('Klaim Garansi Berhasil'), findsWidgets);
      },
    );

    testWidgets('3. Lock form fields when there is an existing claim history', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final controller = Get.find<KlaimGaransiController>();

      // Mensimulasikan kondisi di mana user sudah pernah mengajukan klaim garansi sebelumnya
      controller.warrantyClaims.value = [
        WarrantyModel(
          id: 'claim_123',
          status: 'Diproses',
          complaint: 'Knalpot nembak-nembak',
          serviceHistoryId: {
            '_id': 'hist_999',
          }, // ID COCOK dengan serviceHistory dummy di atas
        ),
      ];
      await tester.pumpAndSettle();

      // UI otomatis mendeteksi hasExistingClaim dan memunculkan info banner biru
      expect(find.text('Klaim Garansi Sudah Diajukan'), findsOneWidget);
      expect(find.text('Knalpot nembak-nembak'), findsOneWidget);
      expect(find.text('Status: '), findsOneWidget);
    });
  });
}
