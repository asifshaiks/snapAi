import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class DocumentScannerController extends GetxController {
  final RxString imagePath = ''.obs;
  final RxString extractedText = ''.obs;
  final RxString translatedText = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isTranslating = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxString detectedLanguage = 'Unknown'.obs;

  // Selected target language for translation
  final RxString targetLanguage = 'en'.obs; // Default: English

  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final FlutterTts flutterTts = FlutterTts();

  OnDeviceTranslator? translator;

  final List<Map<String, String>> availableLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'pt', 'name': 'Portuguese'},
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['imagePath'] != null) {
      imagePath.value = args['imagePath'];
      processImage();
    }

    // Initialize TTS
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);
  }

  Future<void> processImage() async {
    try {
      isProcessing.value = true;

      final inputImage = InputImage.fromFilePath(imagePath.value);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      extractedText.value = recognizedText.text;

      if (extractedText.value.isNotEmpty) {
        // Detect language
        final String language = await languageIdentifier.identifyLanguage(
          extractedText.value,
        );
        detectedLanguage.value = _getLanguageName(language);

        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Success',
          'Text extracted successfully',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'No Text Found',
          'Could not detect any text in the image',
          snackPosition: SnackPosition.TOP,
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

  Future<void> translateText(String targetLang) async {
    if (extractedText.value.isEmpty) return;

    try {
      isTranslating.value = true;
      targetLanguage.value = targetLang;

      // Get source language code
      final String sourceLang = await languageIdentifier.identifyLanguage(
        extractedText.value,
      );

      // Close previous translator if exists
      translator?.close();

      // Create new translator
      translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere(
          (lang) => lang.bcpCode == sourceLang,
          orElse: () => TranslateLanguage.english,
        ),
        targetLanguage: TranslateLanguage.values.firstWhere(
          (lang) => lang.bcpCode == targetLang,
          orElse: () => TranslateLanguage.english,
        ),
      );

      translatedText.value = await translator!.translateText(
        extractedText.value,
      );

      HapticFeedback.lightImpact();
      Get.snackbar(
        'Translated',
        'Text translated to ${_getLanguageName(targetLang)}',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Translation Error',
        'Failed to translate: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isTranslating.value = false;
    }
  }

  Future<void> speakText(String text) async {
    if (text.isEmpty) return;

    try {
      if (isSpeaking.value) {
        await flutterTts.stop();
        isSpeaking.value = false;
      } else {
        isSpeaking.value = true;
        await flutterTts.speak(text);
        isSpeaking.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to speak text: $e',
        snackPosition: SnackPosition.TOP,
      );
      isSpeaking.value = false;
    }
  }

  void copyToClipboard(String text) {
    if (text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Copied',
      'Text copied to clipboard',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }

  String _getLanguageName(String code) {
    final lang = availableLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': 'Unknown'},
    );
    return lang['name']!;
  }

  @override
  void onClose() {
    textRecognizer.close();
    languageIdentifier.close();
    translator?.close();
    flutterTts.stop();
    super.onClose();
  }
}
