import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_pelanggan/app/modules/notification/views/notification_view.dart';
import 'package:speedlab_pelanggan/app/modules/notification/controllers/notification_controller.dart';
import 'package:speedlab_pelanggan/app/data/providers/notif_provider.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/controllers/riwayat_booking_controller.dart';

class MyHttpOverrides extends HttpOverrides {}

// ==================== MOCK PROVIDERS ====================
class MockNotifProvider extends GetConnect implements NotifProvider {
  @override
  Future<Response<dynamic>> getAllNotifications() async {
    return Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': [
          {
            '_id': 'notif_111',
            'title': 'Booking Terverifikasi',
            'body':
                'Booking Anda dengan ID #book1111 telah berhasil diverifikasi oleh admin.',
            'isRead': false,
            'type': 'booking',
            'relatedId': 'book1111',
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            '_id': 'notif_222',
            'title': 'Servis Selesai',
            'body':
                'Sepeda motor Anda selesai dikerjakan mekanik. Silakan lakukan pembayaran.',
            'isRead': true,
            'type': 'booking',
            'relatedId': 'book2222',
            'createdAt':
                DateTime.now()
                    .subtract(const Duration(hours: 2))
                    .toIso8601String(),
          },
        ],
      },
    );
  }

  @override
  Future<Response<dynamic>> markAllAsRead() async {
    return const Response(statusCode: 200, body: {'success': true});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK GLOBAL CONTROLLERS ====================
class MockDashboardController extends GetxController
    implements DashboardController {
  @override
  void changePage(int index) {
    debugPrint("⚡ Bypassed Dashboard changePage ke indeks: $index");
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRiwayatBookingController extends GetxController
    implements RiwayatBookingController {
  @override
  void openModalFromNotification(String relatedId) {
    debugPrint("⚡ Bypassed openModalFromNotification untuk ID: $relatedId");
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ==================== MOCK CONTROLLER UTAMA ====================
class MockNotificationController extends NotificationController {
  MockNotificationController() : super(provider: MockNotifProvider());
}

/// Integration Test untuk Notification Page
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Page Integration Test', () {
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
      // 1. Suntikkan dependensi tiruan eksternal PALING AWAL sebelum controller utama memanggil Get.find
      Get.put<NotifProvider>(MockNotifProvider());
      Get.put<DashboardController>(MockDashboardController());
      Get.put<RiwayatBookingController>(MockRiwayatBookingController());

      // 2. Daftarkan controller utama halaman notifikasi
      Get.put<NotificationController>(MockNotificationController());
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
      return const GetMaterialApp(home: NotificationView());
    }

    testWidgets(
      '1. Page loads and displays notification layout elements correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Notifikasi'), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);

        // Memastikan isi teks dari data dummy ter-render sempurna
        expect(find.text('Booking Terverifikasi'), findsOneWidget);
        expect(find.text('Servis Selesai'), findsOneWidget);
      },
    );

    testWidgets(
      '2. AppBar more menu pop-up actions are clickable and responsive',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        final moreButton = find.byIcon(Icons.more_vert);
        expect(moreButton, findsOneWidget);

        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        // Memastikan menu item dropdown muncul pasca klik
        final readAllMenu = find.text('Tandai semua telah dibaca');
        expect(readAllMenu, findsOneWidget);

        await tester.tap(readAllMenu);
        await tester.pumpAndSettle();
      },
    );

    testWidgets('3. Notification tiles display status icons and are tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      expect(find.byIcon(Icons.notifications_outlined), findsWidgets);

      // Ketuk item notifikasi pertama untuk memicu alur redirect rute dashboard
      final firstTile = find.byType(ListTile).first;
      await tester.tap(firstTile);
      await tester.pumpAndSettle();
    });

    testWidgets('4. Pull down refresh indicator reload works smoothly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Seret ListView ke bawah untuk memicu onRefresh data
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Booking Terverifikasi'), findsOneWidget);
    });

    testWidgets(
      '5. Can perform multiple scroll operations through single view list',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        for (int i = 0; i < 3; i++) {
          await tester.drag(find.byType(ListView), const Offset(0, -50));
          await tester.pumpAndSettle();
        }

        expect(find.text('Notifikasi'), findsOneWidget);
      },
    );

    testWidgets(
      '6. Empty state displays correctly when notification list is clear',
      (WidgetTester tester) async {
        // Kosongkan list data secara paksa untuk menguji UI layar kosong
        Get.find<NotificationController>().notifications.clear();
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('Belum ada notifikasi'), findsOneWidget);
        expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      },
    );
  });
}
