import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/document_scanner_controller.dart';

class DocumentScannerPage extends GetView<DocumentScannerController> {
  const DocumentScannerPage({super.key});
  //test

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Obx(
        () => controller.isProcessing.value
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.black),
                    SizedBox(height: 16.h),
                    Text(
                      'Processing image...',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Captured Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(controller.imagePath.value),
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Detected Language
                      if (controller.extractedText.value.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.language, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Detected: ${controller.detectedLanguage.value}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 16.h),

                      // Extracted Text Section
                      _buildTextCard(
                        title: 'Extracted Text',
                        text: controller.extractedText.value,
                        onSpeak: () => controller.speakText(
                          controller.extractedText.value,
                        ),
                        onCopy: () => controller.copyToClipboard(
                          controller.extractedText.value,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Translation Section
                      if (controller.extractedText.value.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Translate to:',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: controller.targetLanguage.value,
                              items: controller.availableLanguages.map((lang) {
                                return DropdownMenuItem(
                                  value: lang['code'],
                                  child: Text(lang['name']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.translateText(value);
                                }
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        controller.isTranslating.value
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              )
                            : controller.translatedText.value.isNotEmpty
                            ? _buildTextCard(
                                title: 'Translated Text',
                                text: controller.translatedText.value,
                                onSpeak: () => controller.speakText(
                                  controller.translatedText.value,
                                ),
                                onCopy: () => controller.copyToClipboard(
                                  controller.translatedText.value,
                                ),
                              )
                            : Center(
                                child: TextButton.icon(
                                  onPressed: () => controller.translateText(
                                    controller.targetLanguage.value,
                                  ),
                                  icon: Icon(Icons.translate),
                                  label: Text('Translate'),
                                ),
                              ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextCard({
    required String title,
    required String text,
    required VoidCallback onSpeak,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onSpeak,
                    icon: Obx(
                      () => Icon(
                        controller.isSpeaking.value
                            ? Icons.stop
                            : Icons.volume_up,
                        size: 20.sp,
                      ),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: onCopy,
                    icon: Icon(Icons.copy, size: 20.sp),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            text.isEmpty ? 'No text detected' : text,
            style: TextStyle(
              fontSize: 14.sp,
              color: text.isEmpty ? Colors.grey : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentScannerController>(() => DocumentScannerController());
  }
}
