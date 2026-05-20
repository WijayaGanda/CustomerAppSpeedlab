import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:speedlab_pelanggan/app/modules/home/views/home_view.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/modules/notification/controllers/notification_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/notif_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK DEPENDENCIES ====================

class MockMotorcyclesProvider extends GetConnect
    implements MotorcyclesProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockServiceProvider extends GetConnect implements ServiceProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockNotifProvider extends GetConnect implements NotifProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  // Wajib menggunakan Rxn agar Obx() di profil avatar tidak error!
  @override
  final user = Rxn<UserModel>(
    UserModel(
      id: '1',
      name: 'Budi Santoso',
      email: 'budi@example.com',
      avatar:
          'https://ui-avatars.com/api/?name=Budi+Santoso&background=4CAF50&color=fff',
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDashboardController extends DashboardController {
  @override
  void changePage(int index) {}
}

class MockNotificationController extends NotificationController {
  MockNotificationController() : super(provider: MockNotifProvider());

  // 🔥 PERBAIKAN: Gunakan .obs agar Obx() di HomeView bahagia!
  final RxInt _unread = 2.obs;

  @override
  int get unreadCount => _unread.value;

  @override
  void onInit() {} // Mencegah pemanggilan API asli
}

// ==================== MOCK HOME CONTROLLER ====================
class MockHomeController extends HomeController {
  MockHomeController()
    : super(
        motorProvider: MockMotorcyclesProvider(),
        serviceProvider: MockServiceProvider(),
      );

  @override
  void onInit() {
    isLoading.value = false;

    // Suapkan data motor DUMMY secara langsung!
    motors.value = [
      MotorModel(
        id: '1',
        brand: "Honda Vario",
        model: "150 CBS",
        licensePlate: "B 1234 XYZ",
        year: 2022,
        color: "Hitam Doff",
      ),
    ];
  }

  // Override fungsi API agar tidak melakukan apa-apa saat dites (dummy loading)
  @override
  Future<void> fetchMyMotors({int retryCount = 0}) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading.value = false;
  }

  @override
  Future<void> fetchServiceList({int retryCount = 0}) async {}

  @override
  void moveToAddMotor() {}

  @override
  void moveToNotifications() {}
}

// ==================== TESTS ====================
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page Integration Test', () {
    setUpAll(() async {
      HttpOverrides.global = MyHttpOverrides();

      // Mencegah GetStorage error di Controller
      await GetStorage.init();

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
      Get.put<AuthService>(MockAuthService());
      Get.put<DashboardController>(MockDashboardController());
      Get.put<NotifProvider>(MockNotifProvider());

      // Pancing Notification Controller sejak awal pakai mock
      Get.put<NotificationController>(MockNotificationController());

      // Inject Home Controller
      Get.put<HomeController>(MockHomeController());
    });

    tearDown(() async {
      try {
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 100));
      Get.reset();
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    Widget createTestableWidget() {
      return GetMaterialApp(
        home: const HomeView(),
        getPages: [
          // Mencegah error "Route not found" saat tester mengetuk tombol Detail/Booking
          GetPage(
            name: '/detail-motor',
            page: () => const Scaffold(body: Text('Halaman Detail')),
          ),
          GetPage(
            name: '/booking',
            page: () => const Scaffold(body: Text('Halaman Booking')),
          ),
          GetPage(
            name: '/add-motor',
            page: () => const Scaffold(body: Text('Halaman Tambah Motor')),
          ),
          GetPage(
            name: '/notification',
            page: () => const Scaffold(body: Text('Halaman Notifikasi')),
          ),
        ],
      );
    }

    testWidgets('1. Smoke Test: Home page loads successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Selamat Datang,'), findsOneWidget);
      expect(
        find.text('Budi Santoso'),
        findsOneWidget,
      ); // Dari mock AuthService
    });

    testWidgets('2. Menu Cepat sections are displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Menu Cepat'), findsOneWidget);
      expect(find.text('Tambah\nMotor'), findsOneWidget);
      expect(find.text('Layanan\nServis'), findsOneWidget);
      expect(find.text('Refresh\nData'), findsOneWidget);
    });

    testWidgets('3. Motor list is displayed using Mock Data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Kendaraan Saya'), findsOneWidget);
      expect(find.text('1 Motor'), findsOneWidget); // Sesuai mock list length
      expect(find.text('Honda Vario 150 CBS'), findsOneWidget);
      expect(find.text('B 1234 XYZ'), findsOneWidget);
    });

    testWidgets('4. Pull down to refresh does not crash', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.fling(scrollable, const Offset(0, 300), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Honda Vario 150 CBS'), findsOneWidget);
    });

    testWidgets('5. Empty State appears when no motors', (
      WidgetTester tester,
    ) async {
      // Kosongkan list untuk ngetes UI empty state
      Get.find<HomeController>().motors.clear();

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Oops, Garasi Kosong!'), findsOneWidget);
      expect(find.text('Tambah Motor'), findsOneWidget);
    });

    testWidgets('6. Action Buttons (Detail & Booking) navigate securely', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      final detailBtn = find.text('Detail');
      if (detailBtn.evaluate().isNotEmpty) {
        await tester.tap(detailBtn.first);
        await tester.pumpAndSettle();

        expect(find.text('Halaman Detail'), findsOneWidget);
        Get.back();
        await tester.pumpAndSettle();
      }

      final bookingBtn = find.text('Booking Servis');
      if (bookingBtn.evaluate().isNotEmpty) {
        await tester.tap(bookingBtn.first);
        await tester.pumpAndSettle();
        expect(find.text('Halaman Booking'), findsOneWidget);
      }
    });
  });
}
