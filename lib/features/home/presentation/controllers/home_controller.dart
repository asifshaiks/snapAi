import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  // Camera
  CameraController? cameraController;
  final RxBool isCameraInitialized = false.obs;
  final RxBool isFlashOn = false.obs;

  // Selected Mode
  final RxInt selectedMode =
      4.obs; // 0-Document, 1-Product, 2-Fitness, 3-Photo, 4-Quick

  // Processing State
  final RxBool isProcessing = false.obs;

  // Available cameras
  List<CameraDescription> cameras = [];

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();

      if (status.isGranted) {
        cameras = await availableCameras();

        if (cameras.isNotEmpty) {
          cameraController = CameraController(
            cameras[0],
            ResolutionPreset.high,
            enableAudio: false,
          );

          await cameraController?.initialize();
          isCameraInitialized.value = true;
        }
      } else {
        Get.snackbar(
          'Permission Denied',
          'Camera permission is required to use this app',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize camera: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void changeMode(int mode) {
    selectedMode.value = mode;
    HapticFeedback.lightImpact();
  }

  Future<void> toggleFlash() async {
    if (cameraController != null) {
      isFlashOn.value = !isFlashOn.value;
      await cameraController?.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
      HapticFeedback.lightImpact();
    }
  }

  Future<void> captureAndProcess() async {
    if (isProcessing.value || cameraController == null) return;

    try {
      isProcessing.value = true;
      HapticFeedback.mediumImpact();

      final XFile image = await cameraController!.takePicture();

      // Navigate based on selected mode
      switch (selectedMode.value) {
        case 0:
          Get.toNamed(
            '/document-scanner',
            arguments: {'imagePath': image.path},
          );
          break;
        case 1:
          Get.toNamed('/product-scanner', arguments: {'imagePath': image.path});
          break;
        case 2:
          Get.toNamed('/fitness-pose', arguments: {'imagePath': image.path});
          break;
        case 3:
          Get.toNamed('/photo-organizer', arguments: {'imagePath': image.path});
          break;
        case 4:
          // Quick mode - auto detect what to do
          await processQuickMode(image.path);
          break;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> processQuickMode(String imagePath) async {
    // Quick mode logic: Try all detections and show most relevant
    // This will be implemented with actual ML Kit processing
    Get.snackbar(
      'Quick Mode',
      'Processing image...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToHistory() {
    Get.toNamed('/history');
    HapticFeedback.lightImpact();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
