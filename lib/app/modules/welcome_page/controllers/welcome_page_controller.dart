import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomePageController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }
}
