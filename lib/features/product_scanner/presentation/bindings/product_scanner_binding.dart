import 'package:aira/features/product_scanner/presentation/controllers/product_scanner_controller.dart';
import 'package:get/get.dart';

class ProductScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductScannerController>(() => ProductScannerController());
  }
}
