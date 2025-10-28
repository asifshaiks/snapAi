import 'package:aira/features/document_scanner/presentation/controllers/document_scanner_controller.dart';
import 'package:get/get.dart';

class DocumentScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentScannerController>(() => DocumentScannerController());
  }
}
