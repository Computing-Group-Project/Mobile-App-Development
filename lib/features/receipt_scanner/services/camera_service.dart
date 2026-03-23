import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isRecordingVideo => _controller?.value.isRecordingVideo ?? false;

  /// Initialize available cameras
  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      rethrow;
    }
  }

  /// Start camera with rear camera (default)
  Future<void> startCamera() async {
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('Cameras not initialized. Call initializeCameras() first');
    }

    try {
      // Use rear camera for receipt scanning
      final CameraDescription rearCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Error starting camera: $e');
      rethrow;
    }
  }

  /// Capture a photo
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      debugPrint('Photo captured: ${photo.path}');
      return photo;
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      return null;
    }
  }

  /// Dispose camera controller
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    debugPrint('Camera disposed');
  }

  /// Check if camera is ready
  bool isCameraReady() {
    return _controller != null &&
        _controller!.value.isInitialized &&
        !_controller!.value.isRecordingVideo;
  }
}