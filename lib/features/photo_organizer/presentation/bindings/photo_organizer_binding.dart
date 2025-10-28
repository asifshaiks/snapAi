import 'package:aira/features/photo_organizer/presentation/controllers/photo_organizer_controller.dart';
import 'package:get/get.dart';

class PhotoOrganizerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhotoOrganizerController>(() => PhotoOrganizerController());
  }
}
