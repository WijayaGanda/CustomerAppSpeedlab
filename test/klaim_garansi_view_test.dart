import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_history_model.dart';
import 'package:speedlab_pelanggan/app/data/models/warranty_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/warranty_claim.dart';
import 'package:speedlab_pelanggan/app/modules/klaim_garansi/controllers/klaim_garansi_controller.dart';
import 'package:speedlab_pelanggan/app/modules/klaim_garansi/views/klaim_garansi_view.dart';

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
class MockKlaimGaransiController extends GetxController
    implements KlaimGaransiController {
  @override
  final serviceHistory = <ServiceHistoryModel>[].obs;
  @override
  final selectedBooking = Rxn<BookingsModel>();
  @override
  final warrantyClaims = <WarrantyModel>[].obs;
  @override
  final isLoading = false.obs;

  @override
  final complaintController = TextEditingController();

  // 🔥 PERBAIKAN: Tambahkan getter hasExistingClaim agar UI tahu harus menampilkan form input!
  @override
  bool get hasExistingClaim => warrantyClaims.isNotEmpty;

  @override
  WarrantyModel? getExistingClaim() => null;

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
  }

  @override
  void onClose() {
    complaintController.dispose();
    super.onClose();
  }

  @override
  Future<void> submitClaim() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockKlaimGaransiController mockController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockController = MockKlaimGaransiController();
    mockController.onInit();
    Get.put<KlaimGaransiController>(mockController);
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
      await tester.pumpWidget(const GetMaterialApp(home: KlaimGaransiView()));
      await tester.pump();
    });
  }

  group('Klaim Garansi View Widget Test', () {
    testWidgets('1. Memastikan Halaman di render', (WidgetTester tester) async {
      await renderView(tester);
      expect(find.byType(KlaimGaransiView), findsOneWidget);
    });

    testWidgets('2. Appbar menampilkan judul yang benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Klaim Garansi'), findsOneWidget);
    });

    testWidgets('3. Informasi kendaraan ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.text('Kendaraan Anda:'), findsOneWidget);
      expect(find.text('B 1234 XYZ'), findsOneWidget);
      expect(find.byIcon(Icons.motorcycle), findsOneWidget);
      expect(find.textContaining('Garansi berlaku hingga:'), findsOneWidget);
    });

    testWidgets('4. Section input keluhan ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.text('Keluhan Anda'), findsWidgets);
      expect(
        find.text('Jelaskan keluhan Anda secara detail'),
        findsOneWidget,
      ); // Hint text
      expect(find.byIcon(Icons.report_problem), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('5. Tombol submit ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.text('Ajukan Klaim Garansi'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
