import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:speedlab_pelanggan/app/data/models/motor_model.dart';
import 'package:speedlab_pelanggan/app/data/models/service_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/notif_provider.dart';
import 'package:speedlab_pelanggan/app/data/providers/service_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_pelanggan/app/modules/home/views/home_view.dart';
import 'package:speedlab_pelanggan/app/modules/notification/controllers/notification_controller.dart';
import 'package:speedlab_pelanggan/app/data/models/user_model.dart';

// ==================== Mocks ====================
class MockGetStorage implements GetStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  Future<Response<dynamic>> getAllNotifications() async {
    return const Response<dynamic>(
      statusCode: 200,
      body: <String, dynamic>{'data': []},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends GetxService implements AuthService {
  @override
  Rxn<UserModel> user = Rxn<UserModel>();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDashboardController extends DashboardController {
  MockDashboardController() : super();
  @override
  void changePage(int index) {}
}

class MockNotificationController extends NotificationController {
  MockNotificationController() : super(provider: MockNotifProvider());
  @override
  void onInit() {}
}

class MockHomeController extends GetxController implements HomeController {
  @override
  RxList<MotorModel> motors = <MotorModel>[].obs;
  @override
  RxList<ServiceModel> service = <ServiceModel>[].obs;
  @override
  RxBool isLoading = false.obs;

  @override
  AuthService get authService => Get.find<AuthService>();
  @override
  DashboardController get dashC => Get.find<DashboardController>();
  @override
  MotorcyclesProvider get motorProvider => MockMotorcyclesProvider();
  @override
  ServiceProvider get serviceProvider => MockServiceProvider();
  @override
  GetStorage get box => MockGetStorage();

  @override
  final GlobalKey keyProfile = GlobalKey();
  @override
  final GlobalKey keyTambahMotor = GlobalKey();
  @override
  final GlobalKey keyLayanan = GlobalKey();
  @override
  final GlobalKey keyRefresh = GlobalKey();
  @override
  final GlobalKey keyLayananList = GlobalKey();
  @override
  final GlobalKey keyKendaraan = GlobalKey();

  final List<MotorModel> sampleMotors = [
    MotorModel(
      id: '1',
      brand: 'Honda',
      model: 'Vario 150',
      licensePlate: 'B 1234 XYZ',
      year: 2022,
      color: 'Hitam Doff',
    ),
    MotorModel(
      id: '2',
      brand: 'Yamaha',
      model: 'NMAX 155',
      licensePlate: 'B 5678 ABC',
      year: 2023,
      color: 'Merah',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    motors.value = sampleMotors;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Tests ====================
void main() {
  late MockHomeController mockHomeController;
  late MockAuthService mockAuthService;

  setUpAll(() {
    // Izinkan akses internet penuh, biarkan aplikasi hidup layaknya di HP
    HttpOverrides.global = null;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockAuthService.user.value = UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      avatar:
          'https://ui-avatars.com/api/?name=John+Doe&background=4CAF50&color=fff',
    );
    Get.put<AuthService>(mockAuthService);
    Get.put<DashboardController>(MockDashboardController());
    Get.put<NotifProvider>(MockNotifProvider());
    Get.put<NotificationController>(MockNotificationController());

    mockHomeController = MockHomeController();
    Get.put<HomeController>(mockHomeController);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> renderHomeView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 🌟 KUNCI UTAMA: tester.runAsync 🌟
    // Ini mengizinkan download Font & Gambar berjalan secara natural
    // tanpa memicu error "Timer is still pending" saat test selesai.
    await tester.runAsync(() async {
      await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
      await tester.pump();
    });
  }

  group('HomeView Visual Widget Tests', () {
    testWidgets('1. Memastikan halaman utama berhasil di-render', (
      WidgetTester tester,
    ) async {
      await renderHomeView(tester);

      expect(find.text('Selamat Datang,'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Menu Cepat'), findsOneWidget);
      expect(find.text('Kendaraan Saya'), findsOneWidget);
    });

    testWidgets('2. Menampilkan daftar motor dari mock data', (
      WidgetTester tester,
    ) async {
      await renderHomeView(tester);

      expect(find.text('Honda Vario 150'), findsOneWidget);
      expect(find.text('Yamaha NMAX 155'), findsOneWidget);
    });

    testWidgets('3. Menampilkan state kosong (Garasi Kosong)', (
      WidgetTester tester,
    ) async {
      mockHomeController.motors.clear();
      await renderHomeView(tester);

      expect(find.text('Oops, Garasi Kosong!'), findsOneWidget);
    });

    testWidgets('4. Menampilkan state loading (Skeleton)', (
      WidgetTester tester,
    ) async {
      mockHomeController.isLoading.value = true;
      await renderHomeView(tester);

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
