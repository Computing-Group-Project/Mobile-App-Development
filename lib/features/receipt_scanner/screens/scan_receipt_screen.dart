import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import '../services/text_recognition_service.dart';
import '../services/receipt_parser_service.dart';
import '../models/receipt_data.dart';
import '../../finance/screens/add_transaction_screen.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  late final CameraService _cameraService;
  late final TextRecognitionService _textRecognitionService;
  late final ReceiptParserService _parserService;

  ReceiptData? _scannedReceipt;
  String _screenState = 'camera'; // 'camera' | 'processing' | 'results'

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _textRecognitionService = TextRecognitionService();
    _parserService = ReceiptParserService();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      await _cameraService.initializeCameras();
      await _cameraService.startCamera();
      await _textRecognitionService.initialize();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _captureAndProcess() async {
    if (!_cameraService.isCameraReady()) return;

    setState(() {
      _screenState = 'processing';
    });

    try {
      // Step 1: Capture photo
      final XFile? photo = await _cameraService.takePicture();
      if (photo == null) throw Exception('Failed to capture photo');

      // Step 2: Recognize text from photo
      final rawText = await _textRecognitionService.recognizeTextFromFile(photo.path);
      if (rawText.isEmpty) throw Exception('No text detected in image');

      // Step 3: Parse receipt data
      final receipt = _parserService.parseReceipt(rawText);

      setState(() {
        _scannedReceipt = receipt;
        _screenState = 'results';
      });
    } catch (e) {
      setState(() => _screenState = 'camera');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing receipt: $e')),
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _screenState = 'camera';
      _scannedReceipt = null;
    });
  }

  void _confirmReceipt() {
    if (_scannedReceipt == null) return;
    // Navigate to Add Transaction screen with pre-filled data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          prefilledReceiptData: _scannedReceipt,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _textRecognitionService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: _screenState == 'camera'
          ? _buildCameraView(context)
          : _screenState == 'processing'
              ? _buildProcessingView(context)
              : _buildResultsView(context),
    );
  }

  // CAMERA VIEW
  Widget _buildCameraView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_cameraService.controller == null || !_cameraService.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        CameraPreview(_cameraService.controller!),
        
        // Guide overlay
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: CustomPaint(
              painter: ReceiptFramePainter(colorScheme.primary),
              size: const Size(300, 400),
            ),
          ),
        ),

        // Bottom instruction & button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Position receipt within frame',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Capture button
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _captureAndProcess,
                      customBorder: const CircleBorder(),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // PROCESSING VIEW
  Widget _buildProcessingView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  strokeWidth: 4,
                ),
              ),
              Icon(
                Icons.receipt_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Receipt',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Extracting text and data...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // RESULTS VIEW
  Widget _buildResultsView(BuildContext context) {
    final theme = Theme.of(context);
    final receipt = _scannedReceipt!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confidence indicator
          if (receipt.confidence > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getConfidenceColor(receipt.confidence).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getConfidenceColor(receipt.confidence),
                  width: 1,
                ),
              ),
              child: Text(
                'Confidence: ${(receipt.confidence * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getConfidenceColor(receipt.confidence),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Merchant name card
          _buildResultCard(
            context,
            icon: Icons.store,
            label: 'Merchant Name',
            value: receipt.merchantName ?? 'Not detected',
            isEditable: true,
          ),
          const SizedBox(height: 12),

          // Total amount card
          _buildResultCard(
            context,
            icon: Icons.payments,
            label: 'Total Amount',
            value: receipt.totalAmount != null
                ? 'LKR ${receipt.totalAmount!.toStringAsFixed(2)}'
                : 'Not detected',
            isEditable: true,
          ),
          const SizedBox(height: 12),

          // Date card
          _buildResultCard(
            context,
            icon: Icons.calendar_today,
            label: 'Date',
            value: receipt.date != null
                ? '${receipt.date!.day}/${receipt.date!.month}/${receipt.date!.year}'
                : 'Not detected',
            isEditable: true,
          ),
          const SizedBox(height: 24),

          // Raw text preview (expandable)
          _buildRawTextPreview(context, receipt.rawText ?? ''),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _confirmReceipt,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirm'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Result Card Widget
  Widget _buildResultCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isEditable)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Navigate to edit screen
                },
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Raw text preview
  Widget _buildRawTextPreview(BuildContext context, String rawText) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExpansionTile(
      title: Text(
        'Raw OCR Text',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      collapsedBackgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Text(
              rawText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper to get confidence color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

// Receipt frame painter for camera guide
class ReceiptFramePainter extends CustomPainter {
  final Color color;

  ReceiptFramePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final cornerLength = 30.0;

    // Draw corners instead of full rectangle
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Top-left
    canvas.drawLine(rect.topLeft, Offset(rect.left + cornerLength, rect.top), paint);
    canvas.drawLine(rect.topLeft, Offset(rect.left, rect.top + cornerLength), paint);

    // Top-right
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      rect.topRight,
      paint,
    );
    canvas.drawLine(
      rect.topRight,
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      rect.bottomLeft,
      paint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      rect.bottomRight,
      Offset(rect.right - cornerLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
