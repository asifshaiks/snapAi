import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ProductScannerController extends GetxController {
  final RxString imagePath = ''.obs;
  final RxBool isProcessing = false.obs;

  // Barcode results
  final RxList<Barcode> barcodes = <Barcode>[].obs;

  // Image labels
  final RxList<ImageLabel> labels = <ImageLabel>[].obs;

  // Extracted text (for product names/details)
  final RxString extractedText = ''.obs;

  final barcodeScanner = BarcodeScanner();
  final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['imagePath'] != null) {
      imagePath.value = args['imagePath'];
      processImage();
    }
  }

  Future<void> processImage() async {
    try {
      isProcessing.value = true;

      final inputImage = InputImage.fromFilePath(imagePath.value);

      // Run all three detections in parallel
      await Future.wait([
        scanBarcode(inputImage),
        labelImage(inputImage),
        extractText(inputImage),
      ]);

      if (barcodes.isEmpty && labels.isEmpty && extractedText.value.isEmpty) {
        Get.snackbar(
          'No Results',
          'Could not detect any product information',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Success',
          'Product information extracted',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process image: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> scanBarcode(InputImage inputImage) async {
    try {
      final List<Barcode> foundBarcodes = await barcodeScanner.processImage(
        inputImage,
      );
      barcodes.value = foundBarcodes;
    } catch (e) {
      print('Barcode scanning error: $e');
    }
  }

  Future<void> labelImage(InputImage inputImage) async {
    try {
      final List<ImageLabel> foundLabels = await imageLabeler.processImage(
        inputImage,
      );
      // Filter labels with confidence > 0.6
      labels.value = foundLabels
          .where((label) => label.confidence > 0.6)
          .toList();
    } catch (e) {
      print('Image labeling error: $e');
    }
  }

  Future<void> extractText(InputImage inputImage) async {
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      extractedText.value = recognizedText.text;
    } catch (e) {
      print('Text recognition error: $e');
    }
  }

  void copyBarcodeValue(String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Copied',
      'Barcode value copied to clipboard',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }

  // String getBarcodeType(BarcodeType type) {
  // switch (type) {
  //   case BarcodeType.ean13:
  //     return 'EAN-13';
  //   case BarcodeType.ean8:
  //     return 'EAN-8';
  //   case BarcodeType.upca:
  //     return 'UPC-A';
  //   case BarcodeType.upce:
  //     return 'UPC-E';
  //   case BarcodeType.code128:
  //     return 'Code 128';
  //   case BarcodeType.code39:
  //     return 'Code 39';
  //   case BarcodeType.qrCode:
  //     return 'QR Code';
  //   case BarcodeType.dataMatrix:
  //     return 'Data Matrix';
  //   default:
  //     return 'Unknown';
  // }
  // }

  @override
  void onClose() {
    barcodeScanner.close();
    imageLabeler.close();
    textRecognizer.close();
    super.onClose();
  }
}
