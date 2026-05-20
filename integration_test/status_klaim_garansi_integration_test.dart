import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/warranty_model.dart';

import 'package:speedlab_pelanggan/app/modules/status_klaim_garansi/views/status_klaim_garansi_view.dart';
import 'package:speedlab_pelanggan/app/modules/status_klaim_garansi/controllers/status_klaim_garansi_controller.dart';
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
          '_id': 'hist_777',
          'status': 'Selesai',
          'warrantyExpiry':
              DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'motorcycleId': {
            '_id': 'motor_555',
            'brand': 'Yamaha',
            'model': 'NMAX',
            'licensePlate': 'L 5678 JKL',
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
    return Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': [
          {
            '_id': 'claim_000',
            'status': 'Diproses',
            'complaint': 'Mesin mendadak mati total saat dikendarai',
            'rejectionReason': null,
            'claimDate': DateTime.now().toIso8601String(),
            'serviceHistoryId': {'_id': 'hist_777'},
          },
        ],
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK CONTROLLER ====================
class MockStatusKlaimGaransiController extends StatusKlaimGaransiController {
  MockStatusKlaimGaransiController()
    : super(
        provider: MockServiceHistoryProvider(),
        warrantyProvider: MockWarrantyClaimProvider(),
      );
}

/// Integration Test untuk Status Klaim Garansi Page
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Status Klaim Garansi Page Integration Test', () {
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
      // 1. Daftarkan mock providers ke memori GetX
      Get.put<ServiceHistoryProvider>(MockServiceHistoryProvider());
      Get.put<WarrantyClaimProvider>(MockWarrantyClaimProvider());

      // 2. Suntikkan Get.arguments agar siklus onInit tidak null pointer crash
      Get.testMode = true;
      Get.routing.args = BookingsModel(id: 'book_777');

      // 3. Pasang controller utama menggunakan Mock
      Get.put<StatusKlaimGaransiController>(MockStatusKlaimGaransiController());
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
      return const GetMaterialApp(home: StatusKlaimGaransiView());
    }

    testWidgets(
      '1. Page loads and displays motorcycle layout elements correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Status Klaim Garansi'), findsWidgets);
        expect(find.text('Kendaraan Anda:'), findsOneWidget);
        expect(
          find.text('L 5678 JKL'),
          findsOneWidget,
        ); // Memastikan plat nomor dummy ter-render
      },
    );

    testWidgets(
      '2. Displays complete warranty claim status details accurately',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        // Memastikan status badge ter-render dengan nilai dari data dummy
        expect(find.text('Diproses'), findsOneWidget);

        expect(find.text('Keluhan'), findsOneWidget);
        expect(
          find.text('Mesin mendadak mati total saat dikendarai'),
          findsOneWidget,
        );

        expect(find.text('Alasan Penolakan'), findsOneWidget);
        expect(find.text('Tanggal Klaim'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Refresh button in AppBar triggers pull data reload smoothly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        final refreshButton = find.byIcon(Icons.refresh);
        expect(refreshButton, findsOneWidget);

        await tester.tap(refreshButton);
        await tester.pumpAndSettle();

        expect(find.text('Diproses'), findsOneWidget);
      },
    );

    testWidgets(
      '4. SingleChildScrollView facilitates normal layout scrolling operations',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -100));
          await tester.pumpAndSettle();
        }

        expect(find.byType(Scaffold), findsOneWidget);
      },
    );

    testWidgets(
      '5. Displays rejection reason box effectively when claim is rejected',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        final controller = Get.find<StatusKlaimGaransiController>();

        // 🔥 SOLUSI: Buat objek WarrantyModel baru untuk menimpa objek final lama
        if (controller.warrantyClaims.isNotEmpty) {
          controller.warrantyClaims[0] = WarrantyModel(
            id: 'claim_000',
            status: 'Ditolak', // Ubah status jadi Ditolak
            complaint: 'Mesin mendadak mati total saat dikendarai',
            rejectionReason:
                'Kerusakan akibat kelalaian penggunaan pengguna (jatuh/tabrakan).', // Berikan alasan
            claimDate: DateTime.now(),
            serviceHistoryId: {'_id': 'hist_777'},
          );
          controller.warrantyClaims
              .refresh(); // Picu RxList agar UI Obx tahu ada data baru
        }

        await tester.pumpAndSettle();

        expect(find.text('Ditolak'), findsOneWidget);
        expect(
          find.text(
            'Kerusakan akibat kelalaian penggunaan pengguna (jatuh/tabrakan).',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '6. Empty state displays correctly for service history data absence',
      (WidgetTester tester) async {
        // Kosongkan riwayat servis untuk memicu percabangan 'Tidak ada data riwayat servis'
        Get.find<StatusKlaimGaransiController>().serviceHistory.clear();
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Tidak ada data riwayat servis'), findsOneWidget);
      },
    );

    testWidgets(
      '7. Empty state displays correctly for warranty claims data absence',
      (WidgetTester tester) async {
        // Kosongkan riwayat klaim untuk memicu percabangan 'Belum ada klaim garansi'
        Get.find<StatusKlaimGaransiController>().warrantyClaims.clear();
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Belum ada klaim garansi'), findsOneWidget);
      },
    );
  });
}
