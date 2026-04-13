import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';
// import '';

class ServiceHistoryProvider extends ApiService {
  //APi untuk membuat riwayat servis baru
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    return post('api/service-histories', data);
  }

  //Get Api untuk mendapatkan riwayat servis berdasarkan bookingId
  Future<Response> getServiceHistory(String bookingId) async {
    return get('api/service-histories/booking/$bookingId');
  }

  Future<Response> updateServiceHistory(
    String serviceHistoryId,
    Map<String, dynamic> data,
  ) async {
    return put('api/service-histories/$serviceHistoryId', data);
  }

  Future<Response> confirmServiceHistory(
    String serviceHistoryId,
    Map<String, dynamic> data,
  ) async {
    return put('api/service-histories/$serviceHistoryId', data);
  }
}
