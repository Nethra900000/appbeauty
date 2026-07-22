import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ScanOverlay extends StatefulWidget {
  final bool showGrid;
  final bool showLandmarks;
  final bool isScanning;

  const ScanOverlay({
    Key? key,
    this.showGrid = true,
    this.showLandmarks = true,
    this.isScanning = true,
  }) : super(key: key);

  @override
  _ScanOverlayState createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isScanning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScanOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isScanning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanPainter(
            scanProgress: _controller.value,
            showGrid: widget.showGrid,
            showLandmarks: widget.showLandmarks,
            isScanning: widget.isScanning,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _ScanPainter extends CustomPainter {
  final double scanProgress;
  final bool showGrid;
  final bool showLandmarks;
  final bool isScanning;

  _ScanPainter({
    required this.scanProgress,
    required this.showGrid,
    required this.showLandmarks,
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.scanGrid.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Draw Grid Lines
    if (showGrid) {
      const int rows = 12;
      const int cols = 8;
      
      for (int i = 1; i < rows; i++) {
        final y = (size.height / rows) * i;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      for (int i = 1; i < cols; i++) {
        final x = (size.width / cols) * i;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // 2. Draw Face Shape Guidelines (Oval Outline)
    final faceOutlinePaint = Paint()
      ..color = AppColors.scanGrid.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final Rect ovalRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.6,
    );
    canvas.drawOval(ovalRect, faceOutlinePaint);

    // 3. Draw Facial Landmarks (Forehead, Cheeks, Eyes, Nose, Jawline)
    if (showLandmarks) {
      final landmarkPaint = Paint()
        ..color = AppColors.scanLine
        ..style = PaintingStyle.fill;
      
      final glowPaint = Paint()
        ..color = AppColors.scanLine.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final landmarks = [
        Offset(size.width * 0.5, size.height * 0.22), // Forehead
        Offset(size.width * 0.35, size.height * 0.35), // Left Eye
        Offset(size.width * 0.65, size.height * 0.35), // Right Eye
        Offset(size.width * 0.5, size.height * 0.45), // Nose
        Offset(size.width * 0.3, size.height * 0.5), // Left Cheek
        Offset(size.width * 0.7, size.height * 0.5), // Right Cheek
        Offset(size.width * 0.5, size.height * 0.7), // Chin/Jawline
      ];

      for (var point in landmarks) {
        // Draw glowing radius around point
        canvas.drawCircle(point, 12, glowPaint);
        // Draw actual point
        canvas.drawCircle(point, 4, landmarkPaint);
      }
    }

    // 4. Draw Moving Laser Scan Line
    if (isScanning) {
      final scanY = size.height * 0.15 + (size.height * 0.6 * scanProgress);
      
      final laserPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.scanLine.withOpacity(0.0),
            AppColors.scanLine,
            AppColors.scanLine.withOpacity(0.0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, scanY - 5, size.width, 10))
        ..strokeWidth = 3.0;

      canvas.drawLine(Offset(size.width * 0.15, scanY), Offset(size.width * 0.85, scanY), laserPaint);

      // Add a slight glow overlay below/above the scanning line
      final glowRectPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.scanLine.withOpacity(0.15),
            AppColors.scanLine.withOpacity(0.0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(Rect.fromLTWH(0, scanY - 40, size.width, 40));

      canvas.drawRect(Rect.fromLTRB(size.width * 0.15, scanY - 40, size.width * 0.85, scanY), glowRectPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showLandmarks != showLandmarks ||
        oldDelegate.isScanning != isScanning;
  }
}
