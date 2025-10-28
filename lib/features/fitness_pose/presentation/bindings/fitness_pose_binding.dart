import 'package:aira/features/fitness_pose/presentation/controllers/fitness_pose_controller.dart';
import 'package:get/get.dart';

class FitnessPoseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FitnessPoseController>(() => FitnessPoseController());
  }
}
