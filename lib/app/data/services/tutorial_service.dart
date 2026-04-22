import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TutorialService extends GetxService {
  final box = GetStorage();

  // Tambahkan parameter opsional 'userId'
  bool shouldShowTutorial(String tutorialKey, {String? userId}) {
    // Gabungkan key dasar dengan userId.
    // Jika userId kosong, tetap gunakan key dasar.
    String finalKey = userId != null ? '${tutorialKey}_$userId' : tutorialKey;

    bool isFirstTime = box.read(finalKey) ?? true;

    if (isFirstTime) {
      box.write(finalKey, false);
      return true;
    }
    return false;
  }
}
