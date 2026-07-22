import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ShowcaseDrawer extends StatelessWidget {
  const ShowcaseDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.pastelGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beauty Showcase',
                      style: AppTypography.headlineStyle.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '50 Figma-Ready UI Screens',
                      style: AppTypography.subtitleStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  children: [
                    _buildSection(context, 'Authentication (1-5)', [
                      _ScreenItem('1. Splash Screen', '/splash'),
                      _ScreenItem('2. Onboarding 1 (Face Scan)', '/onboarding1'),
                      _ScreenItem('3. Onboarding 2 (Features)', '/onboarding2'),
                      _ScreenItem('4. Login Screen', '/login'),
                      _ScreenItem('5. Signup Screen', '/signup'),
                    ]),
                    _buildSection(context, 'Home & Navigation (6-10)', [
                      _ScreenItem('6. Home Dashboard', '/home_dashboard'),
                      _ScreenItem('7. Bottom Navigation Wrapper', '/bottom_nav'),
                      _ScreenItem('8. Notifications Screen', '/notifications'),
                      _ScreenItem('9. Search Screen', '/search'),
                      _ScreenItem('10. Voice Assistant / AI Chat', '/chat'),
                    ]),
                    _buildSection(context, 'Face Scanning Flow (11-18)', [
                      _ScreenItem('11. Camera Permission', '/camera_permission'),
                      _ScreenItem('12. Face Scan Screen', '/face_scan'),
                      _ScreenItem('13. Alignment Guide', '/alignment_guide'),
                      _ScreenItem('14. Scanning Animation', '/scanning_animation'),
                      _ScreenItem('15. Upload Image', '/upload_image'),
                      _ScreenItem('16. Confirm / Retake', '/confirm_image'),
                      _ScreenItem('17. Scan Progress', '/scan_progress'),
                      _ScreenItem('18. Scan Success', '/scan_success'),
                    ]),
                    _buildSection(context, 'AI Analysis Results (19-25)', [
                      _ScreenItem('19. Skin Type Result', '/skin_type_result'),
                      _ScreenItem('20. Skin Tone Detection', '/skin_tone_result'),
                      _ScreenItem('21. Face Shape Detection', '/face_shape_result'),
                      _ScreenItem('22. Facial Features Breakdown', '/features_breakdown'),
                      _ScreenItem('23. AI Confidence Score', '/confidence_score'),
                      _ScreenItem('24. Summary Report', '/summary_report'),
                      _ScreenItem('25. Compare Before/After', '/compare_before_after'),
                    ]),
                    _buildSection(context, 'Makeup Recommendation (26-31)', [
                      _ScreenItem('26. Makeup Overview', '/makeup_overview'),
                      _ScreenItem('27. Lipstick Shades', '/lipstick_recommendation'),
                      _ScreenItem('28. Foundation Matching', '/foundation_matching'),
                      _ScreenItem('29. Eye Makeup Styles', '/eye_makeup'),
                      _ScreenItem('30. Full Look Preview', '/makeup_preview'),
                      _ScreenItem('31. Save Makeup Look', '/save_makeup'),
                    ]),
                    _buildSection(context, 'Skincare Recommendation (32-36)', [
                      _ScreenItem('32. Skincare Routine (AM/PM)', '/skincare_routine'),
                      _ScreenItem('33. Product Suggestions', '/skincare_products'),
                      _ScreenItem('34. Ingredient Guide', '/ingredient_recommendation'),
                      _ScreenItem('35. Skin Improvement Tips', '/skincare_tips'),
                      _ScreenItem('36. Skin Progress Tracking', '/skincare_progress'),
                    ]),
                    _buildSection(context, 'Hairstyle Recommendation (37-40)', [
                      _ScreenItem('37. Hairstyle Suggestions', '/hairstyle_suggestions'),
                      _ScreenItem('38. Hairstyle Preview Overlay', '/hairstyle_preview'),
                      _ScreenItem('39. Trending Hairstyles', '/trending_hairstyles'),
                      _ScreenItem('40. Save Hairstyle Screen', '/save_hairstyle'),
                    ]),
                    _buildSection(context, 'Outfit & Color Analysis (41-45)', [
                      _ScreenItem('41. Outfit Color Palette', '/outfit_palette'),
                      _ScreenItem('42. Outfit Recommendations', '/outfit_recommendations'),
                      _ScreenItem('43. Seasonal Suggestions', '/seasonal_fashion'),
                      _ScreenItem('44. Mix & Match Screen', '/mix_match'),
                      _ScreenItem('45. Outfit Preview Screen', '/outfit_preview'),
                    ]),
                    _buildSection(context, 'Profile & Settings (46-50)', [
                      _ScreenItem('46. User Profile', '/profile'),
                      _ScreenItem('47. Saved Looks Gallery', '/saved_looks'),
                      _ScreenItem('48. Settings Screen', '/settings'),
                      _ScreenItem('49. Edit Style Preferences', '/edit_preferences'),
                      _ScreenItem('50. Subscription Upgrade', '/subscription'),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_ScreenItem> items) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.4), width: 1),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: AppTypography.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textLight,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: items.map((item) {
          return ListTile(
            title: Text(
              item.name,
              style: AppTypography.bodyStyle.copyWith(fontSize: 14),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textLight.withOpacity(0.6)),
            onTap: () {
              Navigator.pop(context); // Close Drawer
              Navigator.pushNamed(context, item.route);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ScreenItem {
  final String name;
  final String route;
  _ScreenItem(this.name, this.route);
}
