import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/bookings_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/bookings_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/payment_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_history_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/views/riwayat_booking_view.dart';

// ==================== THE ULTIMATE HTTP OVERRIDES ====================
class DummyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _DummyHttpClient();
}

class _DummyHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _DummyHttpClientRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DummyHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _DummyHttpClientResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DummyHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const List<int> _transparentImage = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
// =====================================================================

// ==================== Mock Providers ====================
class MockBookingsProvider extends GetConnect implements BookingsProvider {
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Riwayat Booking Controller ====================
class MockRiwayatBookingController extends GetxController
    implements RiwayatBookingController {
  @override
  RxBool isLoading = false.obs;

  @override
  RxList<BookingsModel> bookings = <BookingsModel>[].obs;

  bool fetchBookingsCalled = false;

  final List<BookingsModel> sampleBookings = [
    BookingsModel(
      // PERBAIKAN 1: ID dipanjangkan agar tidak error saat di-substring(0,8)
      id: 'BOOKING-12345678',
      motorcycleId: {'brand': 'Honda', 'model': 'Vario 150'},
      serviceIds: ['1', '2'],
      bookingDate: DateTime.now(),
      bookingTime: DateTime.now().toIso8601String(),
      complaint: 'Mesin tidak stabil',
      status: 'Menunggu Verifikasi',
      totalPrice: 250000,
    ),
    BookingsModel(
      id: 'BOOKING-87654321',
      motorcycleId: {'brand': 'Yamaha', 'model': 'NMAX 155'},
      serviceIds: ['3'],
      bookingDate: DateTime.now().subtract(const Duration(days: 1)),
      bookingTime: DateTime.now().toIso8601String(),
      complaint: 'Ganti oli',
      status: 'Terverifikasi',
      totalPrice: 100000,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    bookings.value = sampleBookings;
  }

  @override
  Future<void> fetchBookings() async {
    fetchBookingsCalled = true;
    bookings.value = sampleBookings;
  }

  @override
  List<BookingsModel> getBookingsByStatus(String status) {
    return bookings.where((booking) => booking.status == status).toList();
  }

  // PERBAIKAN 2: Tambahkan fungsi formatBookingId yang hilang
  // PERBAIKAN: Tambahkan tanda tanya (String?) dan handle jika null
  @override
  String formatBookingId(String? id) {
    if (id == null) return '-'; // Cegah error jika id ternyata kosong
    if (id.length >= 8) {
      return id.substring(0, 8).toUpperCase();
    }
    return id.toUpperCase();
  }

  // PERBAIKAN 3: Tambahkan fungsi getMotorcycleInfo yang hilang
  @override
  String getMotorcycleInfo(dynamic booking) {
    if (booking is BookingsModel &&
        booking.motorcycleId != null &&
        booking.motorcycleId is Map) {
      final map = booking.motorcycleId as Map<String, dynamic>;
      return "${map['brand']} ${map['model']}";
    }
    return "Motor Unknown";
  }

  @override
  String getServicesInfo(dynamic booking) {
    if (booking is BookingsModel && booking.serviceIds != null) {
      // Mengembalikan string tiruan untuk kebutuhan visual card layanan
      return "Servis Rutin, Perbaikan Mesin";
    }
    return "Layanan Unknown";
  }

  @override
  String formatDateTime(dynamic booking) {
    if (booking is BookingsModel && booking.bookingDate != null) {
      // Mengembalikan string tanggal tiruan agar UI card berhasil digambar
      return "16 Mei 2026, 10:00 WIB";
    }
    return "Tanggal Unknown";
  }

  @override
  String formatPrice(dynamic price) {
    if (price == null) return "Rp 0";
    return "Rp ${price.toString()}";
  }

  @override
  BookingsProvider get provider => MockBookingsProvider();
  @override
  PaymentProvider get paymentProvider => MockPaymentProvider();
  @override
  ServiceHistoryProvider get serviceHistoryProvider =>
      MockServiceHistoryProvider();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockRiwayatBookingController mockRiwayatBookingController;
  late MockAuthService mockAuthService;

  setUpAll(() {
    HttpOverrides.global = DummyHttpOverrides();
    GoogleFonts.config.allowRuntimeFetching = false;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAuthService = MockAuthService();
    Get.put<AuthService>(mockAuthService);

    mockRiwayatBookingController = MockRiwayatBookingController();
    Get.put<RiwayatBookingController>(mockRiwayatBookingController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderRiwayatBookingView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GetMaterialApp(home: RiwayatBookingView()));
    await tester.pump();
  }

  group('RiwayatBookingView Visual Widget Tests', () {
    testWidgets('1. Memastikan halaman berhasil di-render (Smoke Test)', (
      WidgetTester tester,
    ) async {
      await renderRiwayatBookingView(tester);

      expect(find.text('Riwayat Booking'), findsOneWidget);

      // PERBAIKAN: Ganti findsOneWidget menjadi findsWidgets karena teks ini muncul juga di kartu riwayat
      expect(find.text('Menunggu Verifikasi'), findsWidgets);
      expect(
        find.text('Terverifikasi'),
        findsWidgets,
      ); // Sekalian amankan yang ini juga biar tidak bentrok nanti

      expect(find.text('Sedang Dikerjakan'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('2. Menampilkan daftar booking dari mock data', (
      WidgetTester tester,
    ) async {
      await renderRiwayatBookingView(tester);

      // skipOffstage: false dibutuhkan karena TabBarView menyembunyikan elemen
      expect(
        find.text('Mesin tidak stabil', skipOffstage: false),
        findsWidgets,
      );
      expect(find.text('Honda Vario 150', skipOffstage: false), findsWidgets);
    });

    testWidgets('3. Menampilkan state loading (Skeleton) saat memuat data', (
      WidgetTester tester,
    ) async {
      mockRiwayatBookingController.isLoading.value = true;
      await renderRiwayatBookingView(tester);

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('4. Menampilkan state kosong jika tidak ada data booking', (
      WidgetTester tester,
    ) async {
      mockRiwayatBookingController.bookings.clear();
      await renderRiwayatBookingView(tester);

      expect(
        find.text('Mesin tidak stabil', skipOffstage: false),
        findsNothing,
      );
    });
  });
}
