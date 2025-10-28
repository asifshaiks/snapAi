import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/product_scanner_controller.dart';

class ProductScannerPage extends GetView<ProductScannerController> {
  const ProductScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Scanner'),
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
                      'Scanning product...',
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

                      // Barcode Section
                      if (controller.barcodes.isNotEmpty) ...[
                        _buildSectionHeader('Barcodes Found', Icons.qr_code_2),
                        SizedBox(height: 12.h),
                        ...controller.barcodes.map(
                          (barcode) => _buildBarcodeCard(barcode),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Image Labels Section
                      if (controller.labels.isNotEmpty) ...[
                        _buildSectionHeader('Detected Objects', Icons.label),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: controller.labels.map((label) {
                            return Chip(
                              label: Text(
                                '${label.label} (${(label.confidence * 100).toStringAsFixed(0)}%)',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              backgroundColor: Colors.grey.shade100,
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Extracted Text Section
                      if (controller.extractedText.value.isNotEmpty) ...[
                        _buildSectionHeader('Product Text', Icons.text_fields),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            controller.extractedText.value,
                            style: TextStyle(fontSize: 14.sp, height: 1.5),
                          ),
                        ),
                      ],

                      // No Results Message
                      if (controller.barcodes.isEmpty &&
                          controller.labels.isEmpty &&
                          controller.extractedText.value.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No product information detected',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBarcodeCard(barcode) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "",
                  // controller.getBarcodeType(barcode.type),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    controller.copyBarcodeValue(barcode.displayValue ?? ''),
                icon: Icon(Icons.copy, size: 20.sp),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: EdgeInsets.all(8.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            barcode.displayValue ?? 'No value',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          if (barcode.url?.url != null) ...[
            SizedBox(height: 8.h),
            Text(
              'URL: ${barcode.url!.url}',
              style: TextStyle(fontSize: 12.sp, color: Colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}

class ProductScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductScannerController>(() => ProductScannerController());
  }
}
