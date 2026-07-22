import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/colors.dart';
import 'services/api_service.dart';

// Import all category screen bundles
import 'screens/auth_screens.dart';
import 'screens/home_screens.dart';
import 'screens/scan_screens.dart';
import 'screens/analysis_screens.dart';
import 'screens/makeup_screens.dart';
import 'screens/skincare_screens.dart';
import 'screens/hairstyle_screens.dart';
import 'screens/outfit_screens.dart';
import 'screens/profile_screens.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ApiService(),
      child: const AIBeautyGeniusApp(),
    ),
  );
}

class AIBeautyGeniusApp extends StatelessWidget {
  const AIBeautyGeniusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Beauty Genius',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
      ),
      initialRoute: '/splash',
      routes: {
        // AUTHENTICATION (1-5)
        '/splash': (context) => const SplashScreen(),
        '/onboarding1': (context) => const Onboarding1Screen(),
        '/onboarding2': (context) => const Onboarding2Screen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),

        // HOME & NAVIGATION (6-10)
        '/home_dashboard': (context) => const HomeDashboardScreen(),
        '/bottom_nav': (context) => const BottomNavigationUI(),
        '/notifications': (context) => const NotificationsScreen(),
        '/search': (context) => const SearchScreen(),
        '/chat': (context) => const VoiceAssistantScreen(),

        // FACE SCANNING FLOW (11-18)
        '/camera_permission': (context) => const CameraPermissionScreen(),
        '/face_scan': (context) => const FaceScanScreen(),
        '/alignment_guide': (context) => const FaceAlignmentGuideScreen(),
        '/scanning_animation': (context) => const ScanningAnimationScreen(),
        '/upload_image': (context) => const UploadImageScreen(),
        '/confirm_image': (context) => const ConfirmImageScreen(),
        '/scan_progress': (context) => const ScanProgressScreen(),
        '/scan_success': (context) => const ScanSuccessScreen(),

        // AI ANALYSIS RESULTS (19-25)
        '/skin_type_result': (context) => const SkinTypeResultScreen(),
        '/skin_tone_result': (context) => const SkinToneResultScreen(),
        '/face_shape_result': (context) => const FaceShapeResultScreen(),
        '/features_breakdown': (context) => const FeaturesBreakdownScreen(),
        '/confidence_score': (context) => const ConfidenceScoreScreen(),
        '/summary_report': (context) => const SummaryReportScreen(),
        '/compare_before_after': (context) => const CompareBeforeAfterScreen(),

        // MAKEUP RECOMMENDATION (26-31)
        '/makeup_overview': (context) => const MakeupOverviewScreen(),
        '/lipstick_recommendation': (context) => const LipstickShadesScreen(),
        '/foundation_matching': (context) => const FoundationMatchingScreen(),
        '/eye_makeup': (context) => const EyeMakeupScreen(),
        '/makeup_preview': (context) => const MakeupPreviewScreen(),
        '/save_makeup': (context) => const SaveMakeupLookScreen(),

        // SKINCARE RECOMMENDATION (32-36)
        '/skincare_routine': (context) => const SkincareRoutineScreen(),
        '/skincare_products': (context) => const ProductSuggestionsScreen(),
        '/ingredient_recommendation': (context) => const IngredientRecommendationScreen(),
        '/skincare_tips': (context) => const SkinImprovementTipsScreen(),
        '/skincare_progress': (context) => const ProgressTrackingScreen(),

        // HAIRSTYLE RECOMMENDATION (37-40)
        '/hairstyle_suggestions': (context) => const HairstyleSuggestionsScreen(),
        '/hairstyle_preview': (context) => const HairstylePreviewScreen(),
        '/trending_hairstyles': (context) => const TrendingHairstylesScreen(),
        '/save_hairstyle': (context) => const SaveHairstyleScreen(),

        // OUTFIT & COLOR ANALYSIS (41-45)
        '/outfit_palette': (context) => const OutfitColorPaletteScreen(),
        '/outfit_recommendations': (context) => const OutfitRecommendationsScreen(),
        '/seasonal_fashion': (context) => const SeasonalFashionSuggestionsScreen(),
        '/mix_match': (context) => const MixMatchScreen(),
        '/outfit_preview': (context) => const OutfitPreviewScreen(),

        // USER PROFILE & SETTINGS (46-50)
        '/profile': (context) => const ProfileScreen(),
        '/saved_looks': (context) => const SavedLooksScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit_preferences': (context) => const EditPreferencesScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
      },
    );
  }
}
