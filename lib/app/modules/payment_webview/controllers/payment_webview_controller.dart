import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class PaymentWebviewController extends GetxController {
  late final WebViewController webViewController;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final String paymentUrl = Get.arguments as String;

    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          // Enable DOM storage for Snap SDK
          ..enableZoom(false)
          // Set user agent to avoid blocking
          ..setUserAgent(
            'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                debugPrint('Payment page loading: $url');
                isLoading.value = true;
              },
              onPageFinished: (String url) {
                debugPrint('Payment page loaded: $url');
                isLoading.value = false;
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
                debugPrint('Error code: ${error.errorCode}');
                debugPrint('Error type: ${error.errorType}');
              },
              onNavigationRequest: (NavigationRequest request) {
                debugPrint('Navigation to: ${request.url}');

                // Check for success/failure URLs from Midtrans
                if (request.url.contains('/finish') ||
                    request.url.contains('status_code=200') ||
                    request.url.contains('transaction_status=settlement') ||
                    request.url.contains('transaction_status=pending')) {
                  Get.back(result: true);
                  return NavigationDecision.prevent;
                }

                if (request.url.contains('/error') ||
                    request.url.contains('transaction_status=cancel') ||
                    request.url.contains('transaction_status=deny') ||
                    request.url.contains('transaction_status=expire')) {
                  Get.back(result: false);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
            Uri.parse(paymentUrl),
            headers: {
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            },
          );
  }
}
