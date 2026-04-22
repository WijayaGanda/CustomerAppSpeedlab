import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/models/notif_model.dart';
import 'package:speedlab_pelanggan/app/data/providers/notif_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_pelanggan/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

class NotificationController extends GetxController {
  final NotifProvider provider;

  NotificationController({required this.provider});

  final isLoading = true.obs;

  final notifications = <NotifModel>[].obs;
  final dashC = Get.find<DashboardController>();

  int get unreadCount {
    return notifications.where((notif) => notif.isRead == false).length;
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await provider.getAllNotifications();
      if (response.statusCode == 200) {
        final notifResponse = NotifModelResponse.fromJson(response.body);
        notifications.value = notifResponse.data ?? [];
      } else {
        Get.snackbar('Error', 'Failed to load notifications');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;

      final response = await provider.markAllAsRead();
      if (response.isOk) {
        CustomSnackbar.success("Sukses", "Notifikasi berhasil diubah");
      }
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    } finally {
      isLoading.value = false;
      await fetchNotifications();
    }
  }
}
