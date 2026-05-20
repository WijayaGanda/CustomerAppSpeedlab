import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speedlab_pelanggan/app/data/models/notif_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/notif_provider.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/modules/notification/controllers/notification_controller.dart';
import 'package:speedlab_pelanggan/app/modules/notification/views/notification_view.dart';

// ==================== Mock Providers ====================
class MockNotifProvider extends GetConnect implements NotifProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Mock Controllers ====================
class MockDashboardController extends GetxController
    implements DashboardController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockNotificationController extends GetxController
    implements NotificationController {
  @override
  final notifications = <NotifModel>[].obs;
  @override
  final isLoading = false.obs;

  @override
  NotifProvider get provider => MockNotifProvider();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    notifications.value = [
      NotifModel(
        id: '1',
        userId: '1',
        title: 'Booking Dikonfirmasi',
        body:
            'Booking Anda untuk servis motor telah dikonfirmasi oleh teknisi.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotifModel(
        id: '2',
        userId: '1',
        title: 'Servis Selesai',
        body: 'Servis motor Anda telah selesai. Silahkan ambil di bengkel.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<void> fetchNotifications() async {}

  @override
  Future<void> markAsRead(String notifId) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== Setup & Tests ====================
void main() {
  late MockNotificationController mockController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Tutup Google Fonts runtime fetching
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    Get.put<DashboardController>(MockDashboardController());

    mockController = MockNotificationController();
    mockController.onInit();
    Get.put<NotificationController>(mockController);
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
      await tester.pumpWidget(const GetMaterialApp(home: NotificationView()));
      await tester.pump();
    });
  }

  group('Notification View Widget Test', () {
    testWidgets('1. Smoke test - page renders', (WidgetTester tester) async {
      await renderView(tester);
      expect(find.byType(NotificationView), findsOneWidget);
    });

    testWidgets('2. AppBar displays correct title', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
    });

    testWidgets('3. More options icon displays', (WidgetTester tester) async {
      await renderView(tester);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('4. Notification list displays', (WidgetTester tester) async {
      await renderView(tester);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('5. Notification items display correctly', (
      WidgetTester tester,
    ) async {
      await renderView(tester);
      expect(find.text('Booking Dikonfirmasi'), findsOneWidget);
      expect(find.text('Servis Selesai'), findsOneWidget);
      expect(
        find.textContaining('telah dikonfirmasi oleh teknisi'),
        findsOneWidget,
      );
    });

    testWidgets('6. Empty state displays when no notifications', (
      WidgetTester tester,
    ) async {
      mockController.notifications.clear();
      await renderView(tester);

      expect(find.text('Belum ada notifikasi'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    });

    testWidgets('7. Scaffold renders correctly', (WidgetTester tester) async {
      await renderView(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
