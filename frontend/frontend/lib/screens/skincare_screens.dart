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
// 32. SKINCARE ROUTINE SCREEN (AM/PM)
// ==========================================
class SkincareRoutineScreen extends StatefulWidget {
  const SkincareRoutineScreen({Key? key}) : super(key: key);

  @override
  State<SkincareRoutineScreen> createState() => _SkincareRoutineScreenState();
}

class _SkincareRoutineScreenState extends State<SkincareRoutineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final recs = api.skincareRecs;

    return BeautyScaffold(
      title: 'Skincare Routine',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.wb_sunny_outlined), text: 'Morning (AM)'),
              Tab(icon: Icon(Icons.nights_stay_outlined), text: 'Night (PM)'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMorningList(recs),
                _buildNightList(recs),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'See Product Suggestions',
            onPressed: () => Navigator.pushNamed(context, '/skincare_products'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMorningList(Map<String, dynamic>? recs) {
    if (recs == null || recs['morning'] == null) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStepCard('Step 1: Balance Cleanser', 'Wash with soft foaming gel to cleanse nighttime oils.'),
          _buildStepCard('Step 2: Hydrating Toner', 'Pat Niacinamide toner to tighten pores and maintain pH.'),
          _buildStepCard('Step 3: Lightweight Gel', 'Moisturize with a water-based moisturizer.'),
          _buildStepCard('Step 4: Sun Shield', 'Apply SPF 50 mineral block to protect skin pigments.'),
        ],
      );
    }
    final morning = recs['morning'] as List<dynamic>;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: morning.length,
      itemBuilder: (context, idx) {
        final step = morning[idx];
        return _buildStepCard('Step ${idx + 1}: ${step['step']}', step['desc'] ?? '');
      },
    );
  }

  Widget _buildNightList(Map<String, dynamic>? recs) {
    if (recs == null || recs['night'] == null) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStepCard('Step 1: Oil Cleanse', 'Use oil balm to dissolve cosmetic products.'),
          _buildStepCard('Step 2: Foam Cleanse', 'Perform second cleanse with balanced wash.'),
          _buildStepCard('Step 3: Serum Treatment', 'Apply Salicylic Acid to clear sebum locks inside pores.'),
          _buildStepCard('Step 4: Barrier Recovery', 'Apply thick ceramide cream for overnight skin repair.'),
        ],
      );
    }
    final night = recs['night'] as List<dynamic>;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: night.length,
      itemBuilder: (context, idx) {
        final step = night[idx];
        return _buildStepCard('Step ${idx + 1}: ${step['step']}', step['desc'] ?? '');
      },
    );
  }

  Widget _buildStepCard(String step, String desc) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.3)),
        ],
      ),
    );
  }
}

// ==========================================
// 33. PRODUCT SUGGESTIONS SCREEN
// ==========================================
class ProductSuggestionsScreen extends StatelessWidget {
  const ProductSuggestionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final skinType = api.currentScan?['skin_type'] ?? api.currentUser?['profile']?['skin_type'] ?? 'Combination';

    return BeautyScaffold(
      title: 'Skincare Products',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommended products matching your $skinType skin:', style: const TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
            children: [
              _buildProductCard('Balance Foam Wash', 'Cleanses excess sebum', '\$18.00', 'https://images.unsplash.com/photo-1608248597481-496100c8c836?w=300&auto=format&fit=crop&q=60'),
              _buildProductCard('Niacinamide 10%', 'Refines pores & brightens', '\$24.00', 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=300&auto=format&fit=crop&q=60'),
            ],
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'See Active Ingredients',
            onPressed: () => Navigator.pushNamed(context, '/ingredient_recommendation'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, String desc, String price, String imgUrl) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: AppColors.textLight, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 34. INGREDIENT RECOMMENDATION SCREEN
// ==========================================
class IngredientRecommendationScreen extends StatelessWidget {
  const IngredientRecommendationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final recs = api.skincareRecs;
    
    List<Map<String, String>> ingredients = [
      {"name": "Niacinamide (Vitamin B3)", "benefit": "Regulates oil output, reduces blemishes, and reinforces skin barrier locks.", "strength": "Optimal Concentration: 5% - 10%"},
      {"name": "Salicylic Acid (BHA)", "benefit": "Enters pores deeply to break down dead skin cells and clear blackheads.", "strength": "Optimal Concentration: 1% - 2%"},
      {"name": "Hyaluronic Acid", "benefit": "Binds water molecules to skin cells, supplying deep non-oily moisture.", "strength": "Optimal Concentration: 1% - 3%"},
    ];

    if (recs != null && recs['ingredients'] != null) {
      final list = recs['ingredients'] as List<dynamic>;
      ingredients = list.map((ing) {
        return {
          "name": ing.toString(),
          "benefit": "Selected target compound active matching your skin parameters.",
          "strength": "Optimal AI Picked Concentration",
        };
      }).toList();
    }

    return BeautyScaffold(
      title: 'Active Ingredients',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top active elements selected by AI for your skin concerns:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            itemBuilder: (context, idx) {
              final item = ingredients[idx];
              return _buildIngredientCard(item['name']!, item['benefit']!, item['strength']!);
            },
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'See Skincare Tips',
            onPressed: () => Navigator.pushNamed(context, '/skincare_tips'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(String name, String benefit, String strength) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(benefit, style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.3)),
          const Divider(height: 20),
          Text(strength, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

// ==========================================
// 35. SKIN IMPROVEMENT TIPS SCREEN
// ==========================================
class SkinImprovementTipsScreen extends StatelessWidget {
  const SkinImprovementTipsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final recs = api.skincareRecs;
    
    List<Map<String, String>> tips = [
      {"title": "Double Cleanse Nightly", "details": "Using an oil cleanser first ensures sunscreen and waterproof makeups are completely dissolved before facial wash."},
      {"title": "Damp Skin Application", "details": "Apply Hyaluronic serums on damp skin to seal in maximum moisture, preventing dry check lines."},
      {"title": "Avoid Hot Showers on Face", "details": "Hot water strips natural lipid layers, causing excess oil production on forehead zones."},
    ];

    if (recs != null && recs['tips'] != null) {
      final list = recs['tips'] as List<dynamic>;
      tips = list.map((tip) {
        return {
          "title": "Skincare Habit Guide",
          "details": tip.toString(),
        };
      }).toList();
    }

    return BeautyScaffold(
      title: 'Skincare Tips',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Custom habits to optimize your beauty parameters:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            itemBuilder: (context, idx) {
              final item = tips[idx];
              return _buildTipCard(item['title']!, item['details']!);
            },
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'View Skincare Progress',
            onPressed: () => Navigator.pushNamed(context, '/skincare_progress'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String details) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
          const SizedBox(height: 8),
          Text(details, style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

// ==========================================
// 36. PROGRESS TRACKING SCREEN
// ==========================================
class ProgressTrackingScreen extends StatelessWidget {
  const ProgressTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Skin Tracker',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              children: [
                const Text('SKIN OVERALL SCORE TREND', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1.2, fontSize: 12)),
                const SizedBox(height: 25),
                // Simulated Custom Bar Graph using simple Row / Containers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('Wk 1', 65),
                    _buildBar('Wk 2', 72),
                    _buildBar('Wk 3', 78),
                    _buildBar('Wk 4', 85),
                    _buildBar('Wk 5', 92),
                  ],
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricStat('Hydration', '+24%'),
                    _buildMetricStat('Sebum control', '+15%'),
                    _buildMetricStat('Pore Size', '-8%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'See Hairstyle Recommendations',
            onPressed: () => Navigator.pushNamed(context, '/hairstyle_suggestions'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double score) {
    return Column(
      children: [
        Text('${score.toInt()}', style: GoogleFonts.firaMono(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: score * 1.5, // Scale height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildMetricStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
      ],
    );
  }
}
