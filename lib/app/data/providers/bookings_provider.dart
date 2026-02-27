import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class BookingsProvider extends ApiService {
  Future<Response> addBooking(Map<String, dynamic> data) async {
    return await post('api/bookings', data);
  }
}
