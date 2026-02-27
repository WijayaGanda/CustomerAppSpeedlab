import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class ServiceProvider extends ApiService{
  Future<Response> fetchServices() async {
    return await get('api/services');
  }
}