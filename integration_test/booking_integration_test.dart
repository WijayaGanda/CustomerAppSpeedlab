import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:speedlab_pelanggan/app/modules/booking/views/booking_view.dart';
import 'package:speedlab_pelanggan/app/modules/booking/controllers/booking_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK DEPENDENCIES ====================
class MockServiceProvider extends GetConnect implements ServiceProvider {
  @override
  Future<Response<dynamic>> fetchServices() async {
    // Memberikan daftar layanan dummy agar form tidak kosong
    return Response(
      statusCode: 200,
      body: {
        'data': [
          {
            '_id': 'svc1',
            'name': 'Ganti Oli',
            'description': 'Ganti oli standar',
            'basePrice': 50000,
            'estimatedDuration': 30,
            'category': 'Perawatan',
            'availableAddons': [],
            'variants': [],
          },
        ],
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockBookingsProvider extends GetConnect implements BookingsProvider {
  @override
  Future<Response<dynamic>> fetchBookingsByDate(DateTime date) async {
    // Simulasi hari ini kosong (tidak ada booking)
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response<dynamic>> addBooking(Map<String, dynamic> data) async {
    // Simulasi sukses booking
    return const Response(
      statusCode: 200,
      body: {'success': true, 'message': 'Booking sukses'},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  @override
  final user = Rxn<UserModel>(
    UserModel(id: '1', name: 'Budi Santoso', email: 'budi@example.com'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK CONTROLLER ====================
class MockBookingController extends BookingController {
  MockBookingController()
    : super(
        provider: MockBookingsProvider(),
        serviceProvider: MockServiceProvider(),
        authService: MockAuthService(),
      );

  @override
  void onInit() {
    // KITA BYPASS super.onInit() agar Get.arguments asli tidak membuat error

    // SUAPKAN DATA MOTOR MANUAL (Sesuai nama variabel di Controller Anda)
    selectedMotor.value = MotorModel(
      id: '1',
      brand: 'Yamaha',
      model: 'NMAX 155',
      year: 2023,
      licensePlate: 'L 5678 JKL',
      color: 'Biru Doff',
    );

    // Kita panggil manual fetchServices karena super.onInit dilewati
    fetchServices();
  }
}

/// Integration Test untuk Booking Page (Real Interactions)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Page Integration Test', () {
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
      Get.put<ServiceProvider>(MockServiceProvider());
      Get.put<BookingsProvider>(MockBookingsProvider());
      Get.put<AuthService>(MockAuthService());

      // Pura-pura memberikan args (opsional, karena kita sudah override di MockController)
      Get.testMode = true;

      Get.put<BookingController>(MockBookingController());
    });

    tearDown(() async {
      try {
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
        if (Get.isBottomSheetOpen == true) Get.back();
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 100));
      Get.reset();
      Get.routing.args = null;
    });

    tearDownAll(() {
      FlutterError.onError = FlutterError.presentError;
    });

    Widget createTestableWidget() {
      return GetMaterialApp(
        home: const BookingView(),
        getPages: [
          GetPage(
            name: '/dashboard',
            page: () => const Scaffold(body: Text('Halaman Dashboard')),
          ),
        ],
      );
    }

    testWidgets('1. Page loads and displays Motor Info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Halaman Booking'), findsOneWidget);
      expect(find.text('Kendaraan Anda:'), findsOneWidget);
      expect(
        find.text('L 5678 JKL'),
        findsOneWidget,
      ); // Memastikan plat nomor dummy muncul
    });

    testWidgets('2. Full Booking Flow (Date, Time, Service, Complaint, Submit)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final controller = Get.find<BookingController>();

      // --- A. PILIH TANGGAL (Bypass UI Picker demi keandalan tes) ---
      // UI DatePicker bawaan Flutter agak sulit ditest secara stabil di emulator,
      // jadi kita suapkan nilainya langsung ke controller.
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      controller.selectedDateTime.value = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        0,
        0,
      );
      await tester.pumpAndSettle();

      // --- B. BUKA POPUP JAM ---
      final timePickerButton = find.byIcon(Icons.access_time);
      expect(timePickerButton, findsOneWidget);

      await tester.tap(timePickerButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Pastikan Popup Jam Muncul
      expect(find.text('Pilih Jam Booking'), findsOneWidget);

      // Klik jam 08:00
      final eightAmText = find.text('08:00');
      expect(eightAmText, findsOneWidget);
      await tester.tap(eightAmText);
      await tester.pumpAndSettle();

      // Memastikan UI Waktu berubah
      expect(find.text('08:00'), findsOneWidget);

      // --- C. PILIH LAYANAN ---
      // Buka bottom sheet layanan
      final addServiceButton = find.byIcon(Icons.add_circle_outline);
      await tester.tap(addServiceButton);
      await tester.pumpAndSettle();

      // Centang "Ganti Oli"
      final gantiOliCheckbox = find.text('Ganti Oli');
      expect(gantiOliCheckbox, findsOneWidget);
      await tester.tap(gantiOliCheckbox);
      await tester.pumpAndSettle();

      // Tutup bottom sheet
      await tester.tapAt(const Offset(10, 50)); // Tap di luar bottom sheet
      await tester.pumpAndSettle();

      // Pastikan Ganti Oli muncul di Ringkasan
      expect(find.text('Layanan Terpilih:'), findsOneWidget);

      // --- D. ISI KELUHAN ---
      // Scroll ke bawah
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -400));
        await tester.pumpAndSettle();
      }

      final complaintField = find.byType(TextField);
      if (complaintField.evaluate().isNotEmpty) {
        await tester.enterText(complaintField.first, 'Mesin agak kasar.');
        await tester.pumpAndSettle();
      }

      // --- E. KLIK BOOKING ---
      final submitButton = find.text('Booking');
      expect(submitButton, findsOneWidget);

      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Berhasil diarahkan ke Dashboard Dummy!
      expect(find.text('Halaman Dashboard'), findsOneWidget);
    });
  });
}
