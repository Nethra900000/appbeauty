import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import '../widgets/scan_overlay.dart';
import 'auth_screens.dart';
import '../services/api_service.dart';
import 'package:camera/camera.dart';

// ==========================================
// 11. CAMERA PERMISSION SCREEN
// ==========================================
class CameraPermissionScreen extends StatelessWidget {
  const CameraPermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Permissions',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            GlassCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 25),
                  Text('Camera Access Required', style: AppTypography.cardTitleStyle.copyWith(fontSize: 22)),
                  const SizedBox(height: 12),
                  Text(
                    'To perform real-time AI face shape, skin tone, and skin type detection, AI Beauty Genius needs access to your camera.',
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitleStyle,
                  ),
                  const SizedBox(height: 25),
                  PremiumButton(
                    text: 'Grant Camera Permission',
                    onPressed: () {
                      Navigator.pushNamed(context, '/face_scan');
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/upload_image');
                    },
                    child: const Text('Or Upload from Gallery', style: TextStyle(color: AppColors.primary)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 12. FACE SCAN SCREEN
// ==========================================
class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({Key? key}) : super(key: key);

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Live Camera Preview or Mock Live Camera feed background fallback
          Positioned.fill(
            child: _isCameraInitialized && _controller != null
                ? CameraPreview(_controller!)
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=60'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          // Scanning cybernetic grid overlay
          const ScanOverlay(showGrid: true, showLandmarks: false, isScanning: false),
          // Header app bar
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Align Face', style: AppTypography.headlineStyle.copyWith(color: Colors.white, fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.flash_off, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Bottom instructions & shutter button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const GlassCard(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Place your face inside the grid. Look straight and keep neutral expression.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pushNamed(context, '/upload_image'),
                    ),
                    // Shutter button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/alignment_guide');
                      },
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: AppColors.primary, width: 4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 32),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 13. FACE ALIGNMENT GUIDE SCREEN
// ==========================================
class FaceAlignmentGuideScreen extends StatelessWidget {
  const FaceAlignmentGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&auto=format&fit=crop&q=60'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Circle mask to guide face alignment
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 340,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(130),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Outline stroke for guiding box
          Center(
            child: Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(130),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Center(
              child: Text(
                'Fit Face in Circle',
                style: AppTypography.headlineStyle.copyWith(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 30,
            right: 30,
            child: Column(
              children: [
                const Text(
                  'Align your eyes and nose inside the layout guidelines.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 25),
                PremiumButton(
                  text: 'Align & Capture',
                  onPressed: () {
                    Navigator.pushNamed(context, '/scanning_animation');
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 14. SCANNING ANIMATION SCREEN
// ==========================================
class ScanningAnimationScreen extends StatefulWidget {
  const ScanningAnimationScreen({Key? key}) : super(key: key);

  @override
  State<ScanningAnimationScreen> createState() => _ScanningAnimationScreenState();
}

class _ScanningAnimationScreenState extends State<ScanningAnimationScreen> {
  int _progress = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progress < 100) {
          _progress++;
        } else {
          _timer.cancel();
          Navigator.pushReplacementNamed(context, '/confirm_image');
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&auto=format&fit=crop&q=60'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Pulsing laser and face scan grid
          const ScanOverlay(showGrid: true, showLandmarks: true, isScanning: true),
          // Dim overlay
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  'AI Analyzing Face...',
                  style: AppTypography.headlineStyle.copyWith(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  'Calibrating skin tones and coordinates',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                Text(
                  '$_progress%',
                  style: GoogleFonts.firaMono(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress / 100.0,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.scanLine),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 15. UPLOAD IMAGE SCREEN
// ==========================================
class UploadImageScreen extends StatelessWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Upload Face Photo',
      body: Column(
        children: [
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                Text('Select Image from Library', style: AppTypography.cardTitleStyle),
                const SizedBox(height: 12),
                Text(
                  'Select a clear portrait shot with neutral lighting. Supported formats: JPG, PNG.',
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitleStyle,
                ),
                const SizedBox(height: 30),
                PremiumButton(
                  text: 'Browse Photo Gallery',
                  icon: Icons.photo_library,
                  onPressed: () {
                    Navigator.pushNamed(context, '/confirm_image');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Tips guide
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tips for accurate analysis:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildTipRow(Icons.wb_sunny_outlined, 'Ensure natural, front-facing lighting.'),
          _buildTipRow(Icons.no_photography_outlined, 'Avoid wearing glasses or thick hats.'),
          _buildTipRow(Icons.face_retouching_off, 'A makeup-free face yields skin texture results.'),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textDark))),
        ],
      ),
    );
  }
}

// ==========================================
// 16. RETAKE / CONFIRM IMAGE SCREEN
// ==========================================
class ConfirmImageScreen extends StatelessWidget {
  const ConfirmImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Captured Face Preview
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&auto=format&fit=crop&q=60'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Confirm Capture',
              style: AppTypography.headlineStyle.copyWith(color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const GlassCard(
                  child: Text(
                    'Is the image clear and well-lit? If yes, click Confirm to run AI analyzer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Retake', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: PremiumButton(
                        text: 'Confirm',
                        onPressed: () {
                          Navigator.pushNamed(context, '/scan_progress');
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 17. SCAN PROGRESS SCREEN
// ==========================================
class ScanProgressScreen extends StatefulWidget {
  const ScanProgressScreen({Key? key}) : super(key: key);

  @override
  State<ScanProgressScreen> createState() => _ScanProgressScreenState();
}

class _ScanProgressScreenState extends State<ScanProgressScreen> {
  double _percent = 0.0;
  late Timer _timer;
  bool _apiCallFinished = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.triggerScanUpload().then((error) {
      if (mounted) {
        setState(() {
          _apiCallFinished = true;
          _apiError = error;
        });
      }
    });

    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        if (_percent < 0.90) {
          _percent += 0.01;
        } else if (_apiCallFinished) {
          if (_percent < 1.0) {
            _percent += 0.02;
          } else {
            _timer.cancel();
            if (_apiError == null) {
              Navigator.pushReplacementNamed(context, '/scan_success');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scan failed: $_apiError')),
              );
              Navigator.pop(context);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'AI Processing',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            GlassCard(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            value: _percent,
                            strokeWidth: 8,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${(_percent * 100).toInt()}%',
                            style: GoogleFonts.firaMono(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('Processing Mesh Data', style: AppTypography.cardTitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'Generating customized makeup foundations, color seasons, skin routines, and hair previews...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 18. SCAN SUCCESS SCREEN
// ==========================================
class ScanSuccessScreen extends StatelessWidget {
  const ScanSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Scan Completed',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            GlassCard(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.check, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 25),
                  Text('Analysis Ready!', style: AppTypography.cardTitleStyle.copyWith(fontSize: 22)),
                  const SizedBox(height: 12),
                  const Text(
                    'AI Beauty Genius has successfully completed your facial feature mapping and skin type parsing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 30),
                  PremiumButton(
                    text: 'View AI Results',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/skin_type_result');
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
