import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class BookingsProvider extends ApiService {
  Future<Response> addBooking(Map<String, dynamic> data) async {
    return await post('api/bookings', data);
  }

  Future<Response> fetchBookings(String id) async {
    return await get(
      'api/bookings/my-bookings',
      query: {'motorcycleId': id.toString()},
    );
  }

  Future<Response> fetchMyBookings() async {
    return await get('api/bookings/my-bookings');
  }

  Future<Response> cancelBooking(String id) async {
    return await patch('api/bookings/$id/cancel', {});
  }

  /// Fetch bookings untuk tanggal tertentu untuk mengecek slot mana yang sudah terisi
  Future<Response> fetchBookingsByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return await get('api/bookings/by-date', query: {'date': formattedDate});
  }
}
