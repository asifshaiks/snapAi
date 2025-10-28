import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PhotoOrganizerController extends GetxController {
  final RxString imagePath = ''.obs;
  final RxBool isProcessing = false.obs;

  // Detected faces
  final RxList<Face> faces = <Face>[].obs;

  // Image labels (tags)
  final RxList<ImageLabel> labels = <ImageLabel>[].obs;

  // Extracted text (dates, locations, etc.)
  final RxString extractedText = ''.obs;

  // Summary
  final RxString photoSummary = ''.obs;
  final RxList<String> suggestedTags = <String>[].obs;

  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
    ),
  );

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

      // Run all detections
      await Future.wait([
        detectFaces(inputImage),
        labelImage(inputImage),
        extractText(inputImage),
      ]);

      generatePhotoSummary();

      HapticFeedback.mediumImpact();
      Get.snackbar(
        'Photo Analyzed',
        'Smart tags generated',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
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

  Future<void> detectFaces(InputImage inputImage) async {
    try {
      final List<Face> detectedFaces = await faceDetector.processImage(
        inputImage,
      );
      faces.value = detectedFaces;
    } catch (e) {
      print('Face detection error: $e');
    }
  }

  Future<void> labelImage(InputImage inputImage) async {
    try {
      final List<ImageLabel> foundLabels = await imageLabeler.processImage(
        inputImage,
      );
      // Filter labels with confidence > 0.65
      labels.value = foundLabels
          .where((label) => label.confidence > 0.65)
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

  void generatePhotoSummary() {
    List<String> summaryParts = [];
    List<String> tags = [];

    // Analyze faces
    if (faces.isNotEmpty) {
      int smilingCount = 0;
      for (var face in faces) {
        if (face.smilingProbability != null && face.smilingProbability! > 0.7) {
          smilingCount++;
        }
      }

      if (faces.length == 1) {
        summaryParts.add('📸 Single person photo');
        tags.add('Portrait');
      } else {
        summaryParts.add('👥 Group photo with ${faces.length} people');
        tags.add('Group');
      }

      if (smilingCount > 0) {
        summaryParts.add(
          '😊 $smilingCount ${smilingCount == 1 ? "person" : "people"} smiling',
        );
        tags.add('Happy');
      }
    }

    // Analyze labels
    if (labels.isNotEmpty) {
      // Categorize labels
      List<String> topLabels = labels
          .take(5)
          .map((label) => label.label)
          .toList();

      summaryParts.add('🏷️ Contains: ${topLabels.join(", ")}');
      tags.addAll(topLabels);

      // Special categories
      if (topLabels.any(
        (l) =>
            l.toLowerCase().contains('food') ||
            l.toLowerCase().contains('dish'),
      )) {
        tags.add('Food');
      }
      if (topLabels.any(
        (l) =>
            l.toLowerCase().contains('outdoor') ||
            l.toLowerCase().contains('nature'),
      )) {
        tags.add('Outdoor');
      }
      if (topLabels.any(
        (l) =>
            l.toLowerCase().contains('pet') ||
            l.toLowerCase().contains('dog') ||
            l.toLowerCase().contains('cat'),
      )) {
        tags.add('Pet');
      }
    }

    // Analyze text
    if (extractedText.value.isNotEmpty) {
      // Check for dates
      if (RegExp(
        r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}',
      ).hasMatch(extractedText.value)) {
        summaryParts.add('📅 Date information found');
        tags.add('Event');
      }

      // Check for locations/places
      if (extractedText.value
          .split('\n')
          .any((line) => line.length < 50 && line.isNotEmpty)) {
        summaryParts.add('📍 Location/place information detected');
        tags.add('Location');
      }
    }

    if (summaryParts.isEmpty) {
      photoSummary.value = 'General photo';
      tags.add('Uncategorized');
    } else {
      photoSummary.value = summaryParts.join('\n');
    }

    suggestedTags.value = tags.toSet().toList(); // Remove duplicates
  }

  int getSmilingFacesCount() {
    return faces
        .where(
          (face) =>
              face.smilingProbability != null && face.smilingProbability! > 0.7,
        )
        .length;
  }

  String getFaceExpression(Face face) {
    if (face.smilingProbability != null && face.smilingProbability! > 0.7) {
      return 'Smiling 😊';
    } else if (face.smilingProbability != null &&
        face.smilingProbability! < 0.3) {
      return 'Neutral 😐';
    }
    return 'Unknown';
  }

  void copyTags() {
    String tagsText = suggestedTags.join(', ');
    Clipboard.setData(ClipboardData(text: tagsText));
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Copied',
      'Tags copied to clipboard',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    faceDetector.close();
    imageLabeler.close();
    textRecognizer.close();
    super.onClose();
  }
}
