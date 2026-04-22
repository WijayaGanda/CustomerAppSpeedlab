import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/services/fcm_service.dart';
import 'package:speedlab_pelanggan/app/data/services/tutorial_service.dart';

import 'app/routes/app_pages.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔔 Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Get.putAsync(() => FCMService().init());

  final authService = Get.put(AuthService());
  // Get.put(TutorialService()); // Inisialisasi TutorialService di awal aplikasi

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Enable in debug mode only
      builder: (context) => MyApp(authService: authService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Speedlab Pelanggan",
      debugShowCheckedModeBanner: false,

      // Device Preview configuration
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      // App routes
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,

      // Theme
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
