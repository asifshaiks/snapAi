import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          Obx(
            () => controller.isCameraInitialized.value
                ? CameraPreview(controller.cameraController!)
                : Center(child: CircularProgressIndicator(color: Colors.black)),
          ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Title
                  Text(
                    'Smart Snap',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      // Flash Toggle
                      Obx(
                        () => IconButton(
                          onPressed: controller.toggleFlash,
                          icon: Icon(
                            controller.isFlashOn.value
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // History Button
                      IconButton(
                        onPressed: controller.navigateToHistory,
                        icon: Icon(Icons.history, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet - Mode Selection
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mode Selector
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(
                          () => Row(
                            children: [
                              _buildModeButton(
                                icon: Icons.document_scanner,
                                label: 'Document',
                                index: 0,
                              ),
                              _buildModeButton(
                                icon: Icons.qr_code_scanner,
                                label: 'Product',
                                index: 1,
                              ),
                              _buildModeButton(
                                icon: Icons.fitness_center,
                                label: 'Fitness',
                                index: 2,
                              ),
                              _buildModeButton(
                                icon: Icons.photo_library,
                                label: 'Photo',
                                index: 3,
                              ),
                              _buildModeButton(
                                icon: Icons.auto_awesome,
                                label: 'Quick',
                                index: 4,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Capture Button
                      Obx(
                        () => GestureDetector(
                          onTap: controller.isProcessing.value
                              ? null
                              : controller.captureAndProcess,
                          child: Container(
                            width: 70.w,
                            height: 70.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(
                                color: Colors.white,
                                width: 4.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: controller.isProcessing.value
                                ? Padding(
                                    padding: EdgeInsets.all(20.r),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3.w,
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 32.sp,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = controller.selectedMode.value == index;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: GestureDetector(
        onTap: () => controller.changeMode(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
