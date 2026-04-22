import 'package:get/get.dart';
import 'package:speedlab_pelanggan/app/data/services/api_service.dart';

class WarrantyClaimProvider extends ApiService {
  Future<Response> submitWarrantyClaim(Map<String, dynamic> claimData) async {
    return await post('api/warranties', claimData);
  }

  Future<Response> getMyWarrantyClaims() async {
    return await get('api/warranties/my-claims');
  }

  Future<Response> fetchMyWarrantyClaims(String? bookingId) async {
    return await get('api/warranties/my-claims/$bookingId');
  }
}
