import 'package:get/get.dart';

import '../modules/add_motor/bindings/add_motor_binding.dart';
import '../modules/add_motor/views/add_motor_view.dart';
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/detail_motor/bindings/detail_motor_binding.dart';
import '../modules/detail_motor/views/detail_motor_view.dart';
import '../modules/edit_motor/bindings/edit_motor_binding.dart';
import '../modules/edit_motor/views/edit_motor_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/klaim_garansi/bindings/klaim_garansi_binding.dart';
import '../modules/klaim_garansi/views/klaim_garansi_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/payment_webview/bindings/payment_webview_binding.dart';
import '../modules/payment_webview/views/payment_webview_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/riwayat_booking/bindings/riwayat_booking_binding.dart';
import '../modules/riwayat_booking/views/riwayat_booking_view.dart';
import '../modules/riwayat_servis/bindings/riwayat_servis_binding.dart';
import '../modules/riwayat_servis/views/riwayat_servis_view.dart';
import '../modules/service/bindings/service_binding.dart';
import '../modules/service/views/service_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/status_klaim_garansi/bindings/status_klaim_garansi_binding.dart';
import '../modules/status_klaim_garansi/views/status_klaim_garansi_view.dart';
import '../modules/welcome_page/bindings/welcome_page_binding.dart';
import '../modules/welcome_page/views/welcome_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.ADD_MOTOR,
      page: () => const AddMotorView(),
      binding: AddMotorBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING,
      page: () => const BookingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_MOTOR,
      page: () => const DetailMotorView(),
      binding: DetailMotorBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT_BOOKING,
      page: () => const RiwayatBookingView(),
      binding: RiwayatBookingBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE,
      page: () => const ServiceView(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_MOTOR,
      page: () => const EditMotorView(),
      binding: EditMotorBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_WEBVIEW,
      page: () => const PaymentWebviewView(),
      binding: PaymentWebviewBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT_SERVIS,
      page: () => const RiwayatServisView(),
      binding: RiwayatServisBinding(),
    ),
    GetPage(
      name: _Paths.KLAIM_GARANSI,
      page: () => const KlaimGaransiView(),
      binding: KlaimGaransiBinding(),
    ),
    GetPage(
      name: _Paths.STATUS_KLAIM_GARANSI,
      page: () => const StatusKlaimGaransiView(),
      binding: StatusKlaimGaransiBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME_PAGE,
      page: () => const WelcomePageView(),
      binding: WelcomePageBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
  ];
}
