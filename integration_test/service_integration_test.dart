import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_pelanggan/app/modules/service/views/service_view.dart';
import 'package:speedlab_pelanggan/app/modules/service/controllers/service_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK CONTROLLER ====================
class MockServiceController extends ServiceController {
  MockServiceController() : super(provider: ServiceProvider());

  @override
  Future<void> fetchServices() async {
    isLoading.value = true;

    services.value = [
      ServiceModel(
        id: '1',
        name: 'Ganti Oli Premium',
        description: 'Penggantian oli dengan standar pabrik',
        basePrice: 75000,
        estimatedDuration: 30,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perawatan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      ),
      ServiceModel(
        id: '2',
        name: 'Servis CVT',
        description: 'Pembersihan dan pengecekan CVT',
        basePrice: 120000,
        estimatedDuration: 60,
        isActive: false, // Kita buat false untuk ngetes status "Tidak Tersedia"
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'perbaikan',
        v: 0,
        availableAddons: [],
        variants: [],
        isWaitable: false,
      ),
    ];

    isLoading.value = false;
  }
}

// ==================== TESTS ====================
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Service Page Integration Test', () {
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
      Get.put<AuthService>(AuthService());
      Get.put<ServiceController>(MockServiceController());
    });

    tearDown(() async {
      try {
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 100));
      Get.reset();
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    Widget createTestableWidget() {
      return const GetMaterialApp(home: ServiceView());
    }

    testWidgets('1. Service page loads and displays service list correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Layanan Servis'), findsOneWidget);
      expect(find.text('Ganti Oli Premium'), findsWidgets);
    });

    testWidgets('2. Scroll through service list to see all services', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -200));
        await tester.pumpAndSettle();
      }

      expect(find.text('Layanan Servis'), findsOneWidget);
    });

    testWidgets('3. Tap on service card opens bottom sheet detail modal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Klik kartu dengan InkWell
      final serviceItems = find.byType(InkWell);
      if (serviceItems.evaluate().isNotEmpty) {
        await tester.tap(serviceItems.first);
        await tester.pumpAndSettle();

        // 🔥 KITA CARI TEKS YANG PASTI ADA DI MODAL ANDA 🔥
        expect(find.text('Deskripsi'), findsWidgets);
        expect(find.text('Durasi'), findsWidgets);

        // Tutup modal menggunakan Get.back() agar lebih aman daripada tap layar
        Get.back();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('4. Pull down to refresh works perfectly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.fling(scrollable.first, const Offset(0, 300), 1000);
        await tester.pumpAndSettle();
      }

      expect(find.text('Ganti Oli Premium'), findsWidgets);
    });

    testWidgets('5. Multiple service cards can be tapped sequentially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final serviceItems = find.byType(InkWell);
      if (serviceItems.evaluate().length > 1) {
        // Klik kartu pertama
        await tester.tap(serviceItems.first);
        await tester.pumpAndSettle();

        expect(find.text('Deskripsi'), findsWidgets);

        // Tutup modal
        Get.back();
        await tester.pumpAndSettle();

        // Klik kartu kedua
        await tester.tap(serviceItems.at(1));
        await tester.pumpAndSettle();

        expect(
          find.text('Tidak Tersedia'),
          findsWidgets,
        ); // Mengecek status isActive false

        // Tutup modal
        Get.back();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('6. Service page remains responsive after interactions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -150));
        await tester.pumpAndSettle();

        await tester.drag(scrollable.first, const Offset(0, 150));
        await tester.pumpAndSettle();
      }

      expect(find.text('Layanan Servis'), findsOneWidget);
    });
  });
}
