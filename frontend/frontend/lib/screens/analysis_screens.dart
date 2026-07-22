import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import 'auth_screens.dart';
import '../services/api_service.dart';

// ==========================================
// 19. SKIN TYPE RESULT SCREEN
// ==========================================
class SkinTypeResultScreen extends StatelessWidget {
  const SkinTypeResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final scan = api.currentScan;
    final skinType = scan?['skin_type'] ?? 'Combination';
    final confidence = scan?['confidence_score'] ?? 96.5;
    final forehead = scan?['zones']?['forehead'] ?? 'Oily / Shiny';
    final cheeks = scan?['zones']?['cheeks'] ?? 'Dry / Normal';
    final jawline = scan?['zones']?['jawline'] ?? 'Firm';

    return BeautyScaffold(
      title: 'Skin Type Analysis',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              children: [
                const Icon(Icons.opacity, size: 56, color: AppColors.primary),
                const SizedBox(height: 15),
                Text('$skinType Skin', style: AppTypography.cardTitleStyle.copyWith(fontSize: 24)),
                const SizedBox(height: 8),
                Text('Confidence Score: $confidence%', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600)),
                const Divider(height: 30),
                _buildAnalysisRow('Forehead Zone', forehead, forehead.contains('Oily') ? 0.8 : 0.4),
                _buildAnalysisRow('Cheeks Zone', cheeks, cheeks.contains('Dry') || cheeks.contains('Redness') ? 0.3 : 0.6),
                _buildAnalysisRow('Jawline Zone', jawline, 0.7),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Skincare Goals for You', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          _buildGoalItem('Balance sebum production in T-Zone'),
          _buildGoalItem('Hydrate dry patches on cheeks'),
          _buildGoalItem('Refine enlarged pores near the nose'),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'See Skin Tone Results',
            onPressed: () => Navigator.pushNamed(context, '/skin_tone_result'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String status, double val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text(status, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 8,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String text) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: AppColors.primary),
        title: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
      ),
    );
  }
}

// ==========================================
// 20. SKIN TONE DETECTION SCREEN
// ==========================================
class SkinToneResultScreen extends StatelessWidget {
  const SkinToneResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final scan = api.currentScan;
    final skinTone = scan?['skin_tone'] ?? 'Warm Beige';
    final hexCode = scan?['skin_tone_hex'] ?? '#E8C3A9';
    final Color toneColor = Color(int.parse(hexCode.replaceFirst('#', '0xFF')));

    return BeautyScaffold(
      title: 'Skin Tone Match',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: toneColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15)
                    ]
                  ),
                ),
                const SizedBox(height: 15),
                Text(skinTone, style: AppTypography.cardTitleStyle.copyWith(fontSize: 24)),
                const SizedBox(height: 5),
                Text('$hexCode • Matched Undertone', style: const TextStyle(color: AppColors.textLight)),
                const Divider(height: 30),
                Text(
                  'Your skin tone is detected as $skinTone with coordinate color $hexCode. Warm and olive shades fit perfectly on your features.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDark, height: 1.4),
                )
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Matched Color Palette', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildColorSwatch(const Color(0xFFE8C3A9), 'Match 100%'),
              _buildColorSwatch(const Color(0xFFDFB396), 'Match 85%'),
              _buildColorSwatch(const Color(0xFFC79879), 'Match 60%'),
              _buildColorSwatch(const Color(0xFFAB7C5D), 'Match 40%'),
            ],
          ),
          const SizedBox(height: 30),
          PremiumButton(
            text: 'See Face Shape Results',
            onPressed: () => Navigator.pushNamed(context, '/face_shape_result'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }
}

// ==========================================
// 21. FACE SHAPE DETECTION SCREEN
// ==========================================
class FaceShapeResultScreen extends StatelessWidget {
  const FaceShapeResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final scan = api.currentScan;
    final faceShape = scan?['face_shape'] ?? 'Oval';

    return BeautyScaffold(
      title: 'Face Shape Match',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              children: [
                const Icon(Icons.face_retouching_natural, size: 64, color: AppColors.primary),
                const SizedBox(height: 15),
                Text('$faceShape Shape', style: AppTypography.cardTitleStyle.copyWith(fontSize: 24)),
                const SizedBox(height: 8),
                const Text('Perfectly Balanced Symmetry', style: TextStyle(color: AppColors.textLight)),
                const Divider(height: 30),
                Text(
                  'Your facial structure resembles a beautiful $faceShape contour. Hairstyles and makeup highlights are tailored to frame this shape.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDark, height: 1.4),
                )
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Geometric Proportions', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          _buildProportionRow('Width-to-Length Ratio', '1 : 1.5 (Optimal)', 0.95),
          _buildProportionRow('Jaw Angle Curvature', 'Softly Curved', 0.8),
          _buildProportionRow('Cheekbone Prominence', 'Medium High', 0.72),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Face Features Breakdown',
            onPressed: () => Navigator.pushNamed(context, '/features_breakdown'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProportionRow(String label, String value, double ratio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==========================================
// 22. FACIAL FEATURES BREAKDOWN SCREEN
// ==========================================
class FeaturesBreakdownScreen extends StatelessWidget {
  const FeaturesBreakdownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final scan = api.currentScan;
    final forehead = scan?['zones']?['forehead'] ?? 'Hydrated';
    final cheeks = scan?['zones']?['cheeks'] ?? 'Normal';
    final jawline = scan?['zones']?['jawline'] ?? 'Firm';

    return BeautyScaffold(
      title: 'Facial Features',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We analyzed 128 key landmark coordinates on your face to construct this breakdown map:',
            style: TextStyle(color: AppColors.textDark, height: 1.4),
          ),
          const SizedBox(height: 20),
          _buildFeatureCard('Forehead Zone', 'Current status: $forehead. Landmark coordinates mapped.'),
          _buildFeatureCard('Eyes & Brows', 'Symmetrical arch brows, almond eye shape with 4mm spacing ratio.'),
          _buildFeatureCard('Nose Bridge', 'Straight nose bridge, ideal nose-to-lip angle (95 degrees).'),
          _buildFeatureCard('Cheekbones & Jaw', 'Cheeks: $cheeks. Jawline: $jawline. Tailored contour recommendations.'),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'View AI Confidence Score',
            onPressed: () => Navigator.pushNamed(context, '/confidence_score'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String zone, String desc) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.radar, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zone, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 23. AI CONFIDENCE SCORE SCREEN
// ==========================================
class ConfidenceScoreScreen extends StatelessWidget {
  const ConfidenceScoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final scan = api.currentScan;
    final confidence = scan?['confidence_score'] ?? 98.4;

    return BeautyScaffold(
      title: 'Confidence Score',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            GlassCard(
              child: Column(
                children: [
                  const Text('AI CLASSIFICATION STABILITY', style: TextStyle(letterSpacing: 1.5, fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                  const SizedBox(height: 20),
                  Text('$confidence%', style: GoogleFonts.firaMono(fontSize: 54, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 10),
                  const Text('Excellent Detection Accuracy', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  _buildMetric('Pixel density match', 'High (1080p)', Colors.green),
                  _buildMetric('Lighting variance', 'Sufficient (+2.5ev)', Colors.green),
                  _buildMetric('Motion blur factor', 'Negligible (0.01)', Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 30),
            PremiumButton(
              text: 'View Summary Report',
              onPressed: () => Navigator.pushNamed(context, '/summary_report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDark)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==========================================
// 24. SUMMARY REPORT SCREEN
// ==========================================
class SummaryReportScreen extends StatelessWidget {
  const SummaryReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final scan = api.currentScan;
    final skinType = scan?['skin_type'] ?? 'Combination';
    final skinTone = scan?['skin_tone'] ?? 'Warm Beige';
    final hexCode = scan?['skin_tone_hex'] ?? '#E8C3A9';
    final faceShape = scan?['face_shape'] ?? 'Oval';

    return BeautyScaffold(
      title: 'Summary Report',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your AI Beauty Scorecard:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 15),
          GlassCard(
            child: Column(
              children: [
                _buildSummaryItem('Skin Type', '$skinType Skin', Icons.opacity),
                _buildSummaryItem('Skin Tone', '$skinTone ($hexCode)', Icons.palette),
                _buildSummaryItem('Face Shape', '$faceShape Geometry', Icons.face),
                _buildSummaryItem('Matched Palette', 'Warm Autumn Colors', Icons.wb_sunny),
                _buildSummaryItem('Focus Concern', 'T-Zone shine balance', Icons.radar),
              ],
            ),
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Compare Before / After',
            onPressed: () => Navigator.pushNamed(context, '/compare_before_after'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String val, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 2),
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15)),
            ],
          )
        ],
      ),
    );
  }
}

// ==========================================
// 25. COMPARE BEFORE/AFTER SCREEN
// ==========================================
class CompareBeforeAfterScreen extends StatefulWidget {
  const CompareBeforeAfterScreen({Key? key}) : super(key: key);

  @override
  State<CompareBeforeAfterScreen> createState() => _CompareBeforeAfterScreenState();
}

class _CompareBeforeAfterScreenState extends State<CompareBeforeAfterScreen> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Before & After',
      body: Column(
        children: [
          const Text(
            'Swipe the slider to preview the AI beauty/makeup recommendations applied to your portrait:',
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 20),
          // Interactive portrait comparison box
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 380,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              ),
              child: Stack(
                children: [
                  // Under image (After - applied styling)
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600&auto=format&fit=crop&q=60',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Over image (Before - natural skin) masked by slider value
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _sliderValue,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&auto=format&fit=crop&q=60'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Vertical divider line
                  AnimatedAlign(
                    duration: Duration.zero,
                    alignment: Alignment(_sliderValue * 2 - 1, 0),
                    child: Container(
                      width: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  // Slider tag labels
                  const Positioned(
                    top: 15,
                    left: 15,
                    child: Text('Natural', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4)])),
                  ),
                  const Positioned(
                    top: 15,
                    right: 15,
                    child: Text('AI Styled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4)])),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Slider(
            value: _sliderValue,
            onChanged: (val) {
              setState(() {
                _sliderValue = val;
              });
            },
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'Go to Makeup Recommendations',
            onPressed: () => Navigator.pushNamed(context, '/makeup_overview'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
