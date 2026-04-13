import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends ApiService {
  Future<Response> createPayment(String id) async {
    // Bungkus ke dalam Map agar menjadi format JSON req.body
    final Map<String, dynamic> bodyData = {
      "bookingId": id, // Pastikan tulisannya persis begini
    };

    debugPrint("=== DATA YANG DIKIRIM KE BACKEND: $bodyData ===");

    // Gunakan fungsi post dari ApiService
    return await post('api/payment/create', bodyData);
  }

  Future<Response> getPaymentStatus(String bookingId) async {
    return await get('api/payment/status/$bookingId');
  }
}
