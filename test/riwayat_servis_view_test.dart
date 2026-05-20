import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_servis/controllers/riwayat_servis_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_servis/views/riwayat_servis_view.dart';

// ==================== Mock Provider ====================
class MockServiceHistoryProvider extends GetConnect
    implements ServiceHistoryProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Controller ====================
class MockRiwayatServisController extends GetxController
    implements RiwayatServisController {
  @override
  final serviceHistory = <ServiceHistoryModel>[].obs;
  @override
  final selectedBooking = Rxn<BookingsModel>();
  @override
  final isLoading = false.obs;

  @override
  ServiceHistoryProvider get provider => MockServiceHistoryProvider();

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
        notes: 'Service berjalan dengan lancar',
      ),
    ];
    selectedBooking.value = BookingsModel(
      id: '1',
      motorcycleId: '1',
      bookingDate: DateTime.now(),
      totalPrice: 500000,
      status: 'selesai',
    );
  }

  @override
  Future<void> fetchServiceHistory(String bookingId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockRiwayatServisController mockController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockController = MockRiwayatServisController();
    mockController.onInit();
    Get.put<RiwayatServisController>(mockController);
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
      await tester.pumpWidget(const GetMaterialApp(home: RiwayatServisView()));
      await tester.pump();
    });
  }

  group('Riwayat Servis View Widget Test', () {
    testWidgets('1. Memastikan Halaman di render', (WidgetTester tester) async {
      await renderView(tester);
      expect(find.byType(RiwayatServisView), findsOneWidget);
    });

    testWidgets('2. Appbar menampilkan judul yang benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Detail Riwayat Servis'), findsOneWidget);
    });

    testWidgets('3. Catatan servis ditampilkan saat riwayat tersedia', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(
        find.textContaining('Service berjalan dengan lancar'),
        findsWidgets,
      );
    });

    testWidgets('4. Menampilkan state kosong saat tidak ada riwayat', (
      WidgetTester tester,
    ) async {
      // Kosongkan riwayat servis untuk memicu tampilan empty state
      mockController.serviceHistory.clear();
      await renderView(tester);

      // Cek teks utama empty state (yang sudah pasti berhasil di run sebelumnya)
      expect(find.text('Belum Ada Riwayat'), findsOneWidget);
    });
  });
}
