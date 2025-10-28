import 'package:get/get.dart';

import '../controllers/history_controller.dart' show HistoryController;

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(() => HistoryController());
  }
}
