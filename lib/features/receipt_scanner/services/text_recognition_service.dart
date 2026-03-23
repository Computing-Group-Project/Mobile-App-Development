import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';

class TextRecognitionService {
  late final TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;

  /// Initialize the text recognizer
  Future<void> initialize() async {
    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _isInitialized = true;
      debugPrint('TextRecognizer initialized');
    } catch (e) {
      debugPrint('Error initializing TextRecognizer: $e');
      rethrow;
    }
  }

  /// Recognize text from an image file
  Future<String> recognizeTextFromFile(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('TextRecognizer not initialized. Call initialize() first');
    }

    try {
      final InputImage inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String text = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          text += '${line.text}\n';
        }
      }

      debugPrint('Text recognized: $text');
      return text;
    } catch (e) {
      debugPrint('Error recognizing text: $e');
      return '';
    }
  }

  /// Get structured text data from recognized text
  /// Returns: {blocks: [...], lines: [...]}
  Future<Map<String, dynamic>> extractStructuredText(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('TextRecognizer not initialized. Call initialize() first');
    }

    try {
      final InputImage inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final List<Map<String, dynamic>> blocks = [];

      for (TextBlock block in recognizedText.blocks) {
        final List<String> lines = [];
        double avgConfidence = 0;
        for (TextLine line in block.lines) {
          lines.add(line.text);
          avgConfidence += (line.confidence ?? 0);
        }
        // Calculate average confidence from lines
        avgConfidence = lines.isNotEmpty ? avgConfidence / lines.length : 0;
        
        blocks.add({
          'text': block.text,
          'lines': lines,
          'confidence': avgConfidence,
        });
      }

      return {
        'blocks': blocks,
        'fullText': recognizedText.text,
      };
    } catch (e) {
      debugPrint('Error extracting structured text: $e');
      return {};
    }
  }

  /// Close and clean up resources
  Future<void> close() async {
    try {
      await _textRecognizer.close();
      _isInitialized = false;
      debugPrint('TextRecognizer closed');
    } catch (e) {
      debugPrint('Error closing TextRecognizer: $e');
    }
  }
}