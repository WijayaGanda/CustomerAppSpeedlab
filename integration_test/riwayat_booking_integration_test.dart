import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';

import 'package:speedlab_pelanggan/app/modules/riwayat_booking/views/riwayat_booking_view.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK PROVIDERS ====================
class MockBookingsProvider extends GetConnect implements BookingsProvider {
  @override
  Future<Response<dynamic>> fetchMyBookings() async {
    return Response(
      statusCode: 200,
      body: {
        'data': [
          {
            '_id': 'book1111',
            'status': 'Menunggu Verifikasi',
            'bookingDate': DateTime.now().toIso8601String(),
            'bookingTime': '09:00',
            'totalPrice': 75000,
            'complaint': 'Ganti oli rutin',
            'motorcycleId': {
              'brand': 'Honda',
              'model': 'Vario 150',
              'licensePlate': 'B 1234 XYZ',
            },
            'bookingDetails': [],
          },
          {
            '_id': 'book2222',
            'status': 'Terverifikasi',
            'bookingDate': DateTime.now().toIso8601String(),
            'bookingTime': '10:00',
            'totalPrice': 120000,
            'complaint': 'Servis CVT',
            'motorcycleId': {
              'brand': 'Yamaha',
              'model': 'NMAX',
              'licensePlate': 'L 5678 JKL',
            },
            'bookingDetails': [],
          },
          {
            '_id': 'book3333',
            'status': 'Sedang Dikerjakan',
            'bookingDate': DateTime.now().toIso8601String(),
            'bookingTime': '11:00',
            'totalPrice': 50000,
            'complaint': 'Ban bocor',
            'motorcycleId': {
              'brand': 'Honda',
              'model': 'Beat',
              'licensePlate': 'N 9999 AA',
            },
            'bookingDetails': [],
          },
          {
            '_id': 'book4444',
            'status': 'Selesai',
            'bookingDate': DateTime.now().toIso8601String(),
            'bookingTime': '13:00',
            'totalPrice': 200000,
            'complaint': 'Turun mesin ringan',
            'motorcycleId': {
              'brand': 'Suzuki',
              'model': 'GSX',
              'licensePlate': 'D 4321 AB',
            },
            'bookingDetails': [],
          },
          {
            '_id': 'book5555',
            'status': 'Dibatalkan',
            'bookingDate': DateTime.now().toIso8601String(),
            'bookingTime': '14:00',
            'totalPrice': 0,
            'complaint': 'Salah pilih jam',
            'motorcycleId': {
              'brand': 'Kawasaki',
              'model': 'Ninja',
              'licensePlate': 'B 9999 BB',
            },
            'bookingDetails': [],
          },
        ],
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPaymentProvider extends GetConnect implements PaymentProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockServiceHistoryProvider extends GetConnect
    implements ServiceHistoryProvider {
  @override
  Future<Response<dynamic>> getServiceHistory(String bookingId) async {
    return const Response(statusCode: 200, body: {'data': null});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK AUTH SERVICE ====================
class MockAuthService extends GetxService implements AuthService {
  @override
  final user = Rxn<UserModel>(
    UserModel(id: '1', name: 'Budi Santoso', email: 'budi@example.com'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK CONTROLLER ====================
class MockRiwayatBookingController extends RiwayatBookingController {
  MockRiwayatBookingController()
    : super(
        provider: MockBookingsProvider(),
        paymentProvider: MockPaymentProvider(),
        serviceHistoryProvider: MockServiceHistoryProvider(),
        authService: MockAuthService(),
      );

  @override
  Future<void> paymentStatusCheck(String bookingId) async {
    debugPrint("⚡ Bypassed payment status check untuk ID: $bookingId");
  }

  @override
  String getPaymentStatus(String? bookingId) {
    return 'Sudah Dibayar';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Riwayat Booking Page Integration Test', () {
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
      Get.put<AuthService>(MockAuthService());
      Get.put<BookingsProvider>(MockBookingsProvider());
      Get.put<PaymentProvider>(MockPaymentProvider());
      Get.put<ServiceHistoryProvider>(MockServiceHistoryProvider());

      Get.put<RiwayatBookingController>(MockRiwayatBookingController());
    });

    tearDown(() async {
      try {
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
        if (Get.isBottomSheetOpen == true) Get.back();
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 100));
      Get.reset();
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    Widget createTestableWidget() {
      return const GetMaterialApp(home: RiwayatBookingView());
    }

    testWidgets(
      '1. Page loads and displays first tab layout elements correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Riwayat Booking'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);

        
        expect(find.textContaining('book1111'), findsOneWidget);
        expect(find.textContaining('B 1234 XYZ'), findsWidgets);
      },
    );

    testWidgets('2. Tab interaction flow and horizontal swipe', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final tabBarView = find.byType(TabBarView);
      await tester.drag(tabBarView, const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.textContaining('book2222'), findsOneWidget);
      expect(find.textContaining('L 5678 JKL'), findsWidgets);

      
      final tabBar = find.byType(TabBar);
      if (tabBar.evaluate().isNotEmpty) {
        await tester.drag(tabBar.first, const Offset(-300, 0));
        await tester.pumpAndSettle();
      }

      
      final selesaiTab = find.text('Selesai');
      await tester.tap(selesaiTab);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.textContaining('book4444'), findsOneWidget);
    });

    testWidgets('3. Refresh data triggers fetchBookings without crash', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final refreshButton = find.byIcon(Icons.refresh_rounded);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('book1111'), findsOneWidget);
    });

    testWidgets(
      '4. Interactive Flow: Open detail sheet and verify modal content',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        final detailButton = find.text('Detail').first;
        expect(detailButton, findsOneWidget);

        await tester.tap(detailButton);
        await tester.pumpAndSettle();

        expect(find.text('Detail Booking'), findsWidgets);
        expect(find.text('No. Booking'), findsWidgets);
        expect(find.text('Total Biaya'), findsWidgets);

        final closeButton = find.text('Tutup');
        expect(closeButton, findsOneWidget);
        await tester.tap(closeButton);
        await tester.pumpAndSettle();
      },
    );

    testWidgets('5. Empty state behavior placeholder test', (
      WidgetTester tester,
    ) async {
      Get.find<RiwayatBookingController>().bookings.clear();
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Riwayat'), findsWidgets);
    });
  });
}
