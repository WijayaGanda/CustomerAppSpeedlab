import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/models/warranty_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';
import 'package:speedlab_pelanggan/app/modules/status_klaim_garansi/controllers/status_klaim_garansi_controller.dart';
import 'package:speedlab_pelanggan/app/modules/status_klaim_garansi/views/status_klaim_garansi_view.dart';

// ==================== Mock Providers ====================
class MockServiceHistoryProvider extends GetConnect
    implements ServiceHistoryProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWarrantyClaimProvider extends GetConnect
    implements WarrantyClaimProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Controller ====================
class MockStatusKlaimGaransiController extends GetxController
    implements StatusKlaimGaransiController {
  @override
  final serviceHistory = <ServiceHistoryModel>[].obs;
  @override
  final selectedBooking = Rxn<BookingsModel>();
  @override
  final warrantyClaims = <WarrantyModel>[].obs;
  @override
  final isLoading = false.obs;

  @override
  ServiceHistoryProvider get provider => MockServiceHistoryProvider();
  @override
  WarrantyClaimProvider get warrantyProvider => MockWarrantyClaimProvider();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    serviceHistory.value = [
      ServiceHistoryModel(
        id: '1',
        motorcycleId: {'licensePlate': 'B 1234 XYZ'},
        serviceIds: ['1'],
        totalPrice: 500000,
        status: 'selesai',
        warrantyExpiry: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
    selectedBooking.value = BookingsModel(
      id: '1',
      motorcycleId: '1',
      bookingDate: DateTime.now(),
      totalPrice: 500000,
      status: 'selesai',
    );
    warrantyClaims.value = [
      WarrantyModel(
        id: '1',
        complaint: 'Motor tidak menyala',
        status: 'pending',
        claimDate: DateTime.now(),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockStatusKlaimGaransiController mockController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Buka akses HTTP untuk image/network, tutup Google Fonts untuk pakai file lokal
    HttpOverrides.global = null;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockController = MockStatusKlaimGaransiController();
    mockController.onInit();
    Get.put<StatusKlaimGaransiController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(
        const GetMaterialApp(home: StatusKlaimGaransiView()),
      );
      await tester.pump();
    });
  }

  group('Status Klaim Garansi View Widget Test', () {
    testWidgets('1. Memastikan Halaman di render', (WidgetTester tester) async {
      await renderView(tester);
      expect(find.byType(StatusKlaimGaransiView), findsOneWidget);
    });

    testWidgets('2. Appbar menampilkan judul dan ikon yang benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Status Klaim Garansi'), findsWidgets);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('3. Informasi kendaraan ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.text('Kendaraan Anda:'), findsOneWidget);
      expect(find.text('B 1234 XYZ'), findsOneWidget);
      expect(find.byIcon(Icons.motorcycle), findsOneWidget);
    });

    testWidgets('4. Informasi expiry garansi ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.textContaining('Garansi berlaku hingga:'), findsOneWidget);
    });

    testWidgets('5. Informasi klaim ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.text('pending'), findsOneWidget); // Status Badge
      expect(find.text('Keluhan'), findsOneWidget);
      expect(find.text('Motor tidak menyala'), findsOneWidget);
      expect(find.text('Tanggal Klaim'), findsOneWidget);
    });
  });
}
