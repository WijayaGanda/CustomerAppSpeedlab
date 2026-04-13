import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/payment_webview_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebviewView extends GetView<PaymentWebviewController> {
  const PaymentWebviewView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran Tagihan")),
      body: Stack(
        children: [
          WebViewWidget(controller: controller.webViewController),
          Obx(
            () =>
                controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
