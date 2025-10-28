import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryItem {
  final String id;
  final String imagePath;
  final String mode;
  final String result;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.imagePath,
    required this.mode,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'mode': mode,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      imagePath: json['imagePath'],
      mode: json['mode'],
      result: json['result'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class HistoryController extends GetxController {
  final RxList<HistoryItem> historyItems = <HistoryItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'All'.obs;

  final List<String> filters = [
    'All',
    'Document',
    'Product',
    'Fitness',
    'Photo',
    'Quick',
  ];

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('scan_history');

      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        historyItems.value =
            decoded.map((item) => HistoryItem.fromJson(item)).toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load history: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveHistoryItem(HistoryItem item) async {
    try {
      historyItems.insert(0, item);
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        historyItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('scan_history', historyJson);
    } catch (e) {
      print('Failed to save history item: $e');
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      historyItems.removeWhere((item) => item.id == id);
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        historyItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('scan_history', historyJson);

      Get.snackbar(
        'Deleted',
        'History item removed',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete item: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearAllHistory() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Clear History'),
          content: Text('Are you sure you want to delete all history items?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        historyItems.clear();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('scan_history');

        Get.snackbar(
          'Cleared',
          'All history items removed',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear history: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<HistoryItem> get filteredItems {
    if (selectedFilter.value == 'All') {
      return historyItems;
    }
    return historyItems
        .where((item) => item.mode == selectedFilter.value)
        .toList();
  }

  String getModeIcon(String mode) {
    switch (mode) {
      case 'Document':
        return '📄';
      case 'Product':
        return '🔍';
      case 'Fitness':
        return '💪';
      case 'Photo':
        return '📸';
      case 'Quick':
        return '⚡';
      default:
        return '📋';
    }
  }
}
