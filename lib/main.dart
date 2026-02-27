import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final authService = Get.put(AuthService());

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
      initialRoute: authService.isLoggedIn ? Routes.DASHBOARD : Routes.LOGIN,
      getPages: AppPages.routes,

      // Theme
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
