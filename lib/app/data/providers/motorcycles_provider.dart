import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class MotorcyclesProvider extends ApiService {
  Future<Response> addMotorCycles(Map<String, dynamic> data) {
    return post("api/motorcycles", data);
  }

  Future<Response> fetchMyMotors() {
    return get("api/motorcycles/my-motorcycles");
  }
}
