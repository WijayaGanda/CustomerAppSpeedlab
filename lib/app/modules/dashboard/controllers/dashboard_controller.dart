import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/modules/profile/views/profile_view.dart';
import 'package:speedlab_pelanggan/app/modules/riwayat_booking/views/riwayat_booking_view.dart';
import 'package:speedlab_pelanggan/app/modules/service/views/service_view.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  final List<Widget> pages = [HomeView(), ServiceView(), RiwayatBookingView(), ProfileView()];

  void changePage(int index) {
    currentIndex.value = index;
  }
}
