import 'package:get/get.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/bindings/home_binding.dart';
import '../../features/document_scanner/presentation/pages/document_scanner_page.dart';
import '../../features/document_scanner/presentation/bindings/document_scanner_binding.dart'
    hide DocumentScannerBinding;
import '../../features/product_scanner/presentation/pages/product_scanner_page.dart';
import '../../features/product_scanner/presentation/bindings/product_scanner_binding.dart'
    hide ProductScannerBinding;
import '../../features/fitness_pose/presentation/pages/fitness_pose_page.dart';
import '../../features/fitness_pose/presentation/bindings/fitness_pose_binding.dart';
import '../../features/photo_organizer/presentation/pages/photo_organizer_page.dart';
import '../../features/photo_organizer/presentation/bindings/photo_organizer_binding.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/history/presentation/bindings/history_binding.dart';

class AppPages {
  static const HOME = '/home';
  static const DOCUMENT_SCANNER = '/document-scanner';
  static const PRODUCT_SCANNER = '/product-scanner';
  static const FITNESS_POSE = '/fitness-pose';
  static const PHOTO_ORGANIZER = '/photo-organizer';
  static const HISTORY = '/history';

  static final routes = [
    GetPage(name: HOME, page: () => const HomePage(), binding: HomeBinding()),
    GetPage(
      name: DOCUMENT_SCANNER,
      page: () => const DocumentScannerPage(),
      binding: DocumentScannerBinding(),
    ),
    GetPage(
      name: PRODUCT_SCANNER,
      page: () => const ProductScannerPage(),
      binding: ProductScannerBinding(),
    ),
    GetPage(
      name: FITNESS_POSE,
      page: () => const FitnessPosePage(),
      binding: FitnessPoseBinding(),
    ),
    GetPage(
      name: PHOTO_ORGANIZER,
      page: () => const PhotoOrganizerPage(),
      binding: PhotoOrganizerBinding(),
    ),
    GetPage(
      name: HISTORY,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
  ];
}
