import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/booking/controllers/booking_controller.dart';
import 'package:speedlab_pelanggan/app/modules/booking/views/booking_view.dart';

// ==================== Mock Providers ====================
class MockBookingsProvider extends GetConnect implements BookingsProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockServiceProvider extends GetConnect implements ServiceProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Controller ====================
class MockBookingController extends GetxController
    implements BookingController {
  @override
  final selectedMotor = Rxn<MotorModel>();
  @override
  final availableServices = <ServiceModel>[].obs;
  @override
  final selectedService = <ServiceModel>[].obs;
  @override
  final selectedVariants = <String, Variant?>{}.obs;
  @override
  final selectedAddons = <String, List<Addon>>{}.obs;
  @override
  final isLoading = false.obs;
  @override
  final complaintCtrl = TextEditingController();
  @override
  final selectedDateTime = Rxn<DateTime>();
  @override
  final isTimeSelected = false.obs;
  @override
  final bookedTimes = <DateTime>[].obs;
  @override
  final isLoadingTimeslots = false.obs;

  @override
  String get bookingDate {
    selectedDateTime.value;
    return '16/05/2026';
  }

  @override
  String get bookingTime {
    isTimeSelected.value;
    selectedDateTime.value;
    return '10:00';
  }

  @override
  int get totalPrice {
    selectedService.length;
    return 150000;
  }

  @override
  double getServicePrice(ServiceModel service) {
    selectedVariants.isEmpty;
    return 150000.0;
  }

  @override
  Variant? getSelectedVariant(String serviceId) => null;

  @override
  List<Addon> getSelectedAddons(String serviceId) => [];

  @override
  bool isTimeSlotDisabled(DateTime timeSlot) => false;

  @override
  bool isTimeSlotBooked(DateTime timeSlot) => false;

  @override
  BookingsProvider get provider => MockBookingsProvider();
  @override
  ServiceProvider get serviceProvider => MockServiceProvider();
  @override
  AuthService get authService => MockAuthService();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    selectedMotor.value = MotorModel(
      id: '1',
      userId: '1',
      brand: 'Honda',
      model: 'Vario 150',
      year: 2022,
      licensePlate: 'B 1234 XYZ',
      color: 'Hitam',
    );

    final sampleService = ServiceModel(
      id: '1',
      name: 'Perbaikan Mesin',
      description: 'Perbaikan kerusakan',
      basePrice: 500000,
      estimatedDuration: 120,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: 'perbaikan',
      v: 0,
      availableAddons: [],
      variants: [],
      isWaitable: false,
    );

    availableServices.value = [sampleService];
    selectedService.value = [sampleService];
    selectedDateTime.value = DateTime.now().add(const Duration(days: 1));
    isTimeSelected.value = true;
  }

  @override
  void onClose() {
    complaintCtrl.dispose();
    super.onClose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockBookingController mockController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Tutup akses internet untuk Google Fonts karena kita sudah punya file lokalnya di folder assets/google_fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockController = MockBookingController();
    mockController.onInit();
    Get.put<BookingController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderBookingView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GetMaterialApp(home: BookingView()));
    await tester.pumpAndSettle();
  }

  group('Booking View Widget Test', () {
    testWidgets('1. Memastikan Halaman di render', (WidgetTester tester) async {
      await renderBookingView(tester);
      expect(find.byType(BookingView), findsOneWidget);
    });

    testWidgets('2. Appbar menampilkan judul yang benar', (
      WidgetTester tester,
    ) async {
      await renderBookingView(tester);
      expect(find.text('Halaman Booking'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('3. Motor info card ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderBookingView(tester);
      expect(find.text('Kendaraan Anda:'), findsOneWidget);
      expect(find.text('B 1234 XYZ'), findsOneWidget);
    });

    testWidgets('4. Ikon motor ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderBookingView(tester);
      expect(find.byIcon(Icons.motorcycle), findsWidgets);
    });

    testWidgets('5. Date time selection section displays', (
      WidgetTester tester,
    ) async {
      await renderBookingView(tester);
      expect(find.text('Pilih Tanggal & Waktu:'), findsOneWidget);
    });

    testWidgets('6. Calendar date picker ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderBookingView(tester);
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
    });

    testWidgets('7. Tanggal Booking label ditampilkan dengan benar', (
      WidgetTester tester,
    ) async {
      await renderBookingView(tester);
      expect(find.text('Tanggal Booking'), findsOneWidget);
    });

    testWidgets('8. Forward arrow icon displays in date picker', (
      WidgetTester tester,
    ) async {
      await renderBookingView(tester);
      expect(find.byIcon(Icons.arrow_forward_ios), findsWidgets);
    });
  });
}
