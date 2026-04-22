import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class NotifProvider extends ApiService {
  Future<Response> registerFcmToken(Map<String, dynamic> data) async {
    return post('api/notifications/register-device', data);
  }

  Future<Response> unregisterFcmToken(Map<String, dynamic> data) async {
    return post('api/notifications/unregister-device', data);
  }

  Future<Response> getAllNotifications() async {
    return get('api/notifications');
  }

  Future<Response> markAllAsRead() async {
    return patch('api/notifications/read/all', {});
  }
}
