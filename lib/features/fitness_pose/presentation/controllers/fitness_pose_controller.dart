import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math' as math;

class FitnessPoseController extends GetxController {
  final RxString imagePath = ''.obs;
  final RxBool isProcessing = false.obs;

  // Pose detection results
  final RxList<Pose> poses = <Pose>[].obs;

  // Face detection results
  final RxList<Face> faces = <Face>[].obs;

  // Analysis results
  final RxString poseAnalysis = ''.obs;
  final RxDouble postureScore = 0.0.obs;

  final poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.single),
  );

  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
    ),
  );

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

      // Detect poses and faces
      await Future.wait([detectPose(inputImage), detectFace(inputImage)]);

      if (poses.isNotEmpty) {
        analyzePose(poses.first);
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Pose Detected',
          'Your posture has been analyzed',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'No Pose Detected',
          'Could not detect any human pose in the image',
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

  Future<void> detectPose(InputImage inputImage) async {
    try {
      final List<Pose> detectedPoses = await poseDetector.processImage(
        inputImage,
      );
      poses.value = detectedPoses;
    } catch (e) {
      print('Pose detection error: $e');
    }
  }

  Future<void> detectFace(InputImage inputImage) async {
    try {
      final List<Face> detectedFaces = await faceDetector.processImage(
        inputImage,
      );
      faces.value = detectedFaces;
    } catch (e) {
      print('Face detection error: $e');
    }
  }

  void analyzePose(Pose pose) {
    final landmarks = pose.landmarks;

    List<String> feedback = [];
    double score = 100.0;

    // Check shoulder alignment
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftShoulder != null && rightShoulder != null) {
      double shoulderDiff = (leftShoulder.y - rightShoulder.y).abs();
      if (shoulderDiff > 50) {
        feedback.add('⚠️ Shoulders are not level');
        score -= 15;
      } else {
        feedback.add('✅ Shoulders are well aligned');
      }
    }

    // Check spine alignment (shoulder to hip)
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder != null && leftHip != null) {
      double spineAngle = calculateAngle(
        leftShoulder.x,
        leftShoulder.y,
        leftHip.x,
        leftHip.y,
      );

      if (spineAngle > 15) {
        feedback.add('⚠️ Leaning too far forward or backward');
        score -= 20;
      } else {
        feedback.add('✅ Good spine alignment');
      }
    }

    // Check knee alignment
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      double kneeAngle = calculateJointAngle(leftHip, leftKnee, leftAnkle);

      if (kneeAngle < 160 && kneeAngle > 30) {
        feedback.add('✅ Knees in good position');
      } else if (kneeAngle < 30) {
        feedback.add('⚠️ Knees bent too much');
        score -= 10;
      }
    }

    // Check if standing upright
    if (leftHip != null && rightHip != null) {
      double hipDiff = (leftHip.y - rightHip.y).abs();
      if (hipDiff > 40) {
        feedback.add('⚠️ Hips are not level');
        score -= 15;
      } else {
        feedback.add('✅ Hips are level');
      }
    }

    // Face position check
    if (faces.isNotEmpty) {
      final face = faces.first;
      if (face.headEulerAngleY != null) {
        if (face.headEulerAngleY!.abs() < 15) {
          feedback.add('✅ Head facing forward');
        } else {
          feedback.add('⚠️ Head turned to the side');
          score -= 10;
        }
      }

      if (face.smilingProbability != null && face.smilingProbability! > 0.7) {
        feedback.add('😊 Great smile!');
      }
    }

    postureScore.value = score.clamp(0, 100);
    poseAnalysis.value = feedback.join('\n');
  }

  double calculateAngle(double x1, double y1, double x2, double y2) {
    double angle = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi;
    return angle.abs();
  }

  double calculateJointAngle(
    PoseLandmark? point1,
    PoseLandmark? point2,
    PoseLandmark? point3,
  ) {
    if (point1 == null || point2 == null || point3 == null) return 0;

    double angle1 = math.atan2(point1.y - point2.y, point1.x - point2.x);
    double angle2 = math.atan2(point3.y - point2.y, point3.x - point2.x);
    double angle = (angle1 - angle2) * 180 / math.pi;

    return angle.abs();
  }

  String getPostureRating() {
    if (postureScore.value >= 90) return 'Excellent';
    if (postureScore.value >= 75) return 'Good';
    if (postureScore.value >= 60) return 'Fair';
    return 'Needs Improvement';
  }

  @override
  void onClose() {
    poseDetector.close();
    faceDetector.close();
    super.onClose();
  }
}
