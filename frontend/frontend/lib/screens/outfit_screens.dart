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
// 41. OUTFIT COLOR PALETTE SCREEN
// ==========================================
class OutfitColorPaletteScreen extends StatelessWidget {
  const OutfitColorPaletteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final recs = api.outfitRecs;
    final season = recs?['season'] ?? 'Warm Autumn';
    final tone = api.currentScan?['skin_tone'] ?? api.currentUser?['profile']?['skin_tone'] ?? 'Warm Beige';
    
    List<Map<String, dynamic>> colors = [
      {"name": "Mustard", "color": const Color(0xFFFFDB58)},
      {"name": "Terracotta", "color": const Color(0xFFE2725B)},
      {"name": "Olive", "color": const Color(0xFF808000)},
      {"name": "Cream", "color": const Color(0xFFFFFDD0)},
    ];

    if (recs != null && recs['colors'] != null) {
      final list = recs['colors'] as List<dynamic>;
      colors = list.map((item) {
        final hexStr = item['hex'] as String? ?? '#808000';
        final color = Color(int.parse(hexStr.replaceFirst('#', '0xFF')));
        return {
          "name": item['name'] ?? 'Color',
          "color": color,
        };
      }).toList();
    }

    return BeautyScaffold(
      title: 'Color Season Analysis',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 56, color: AppColors.primary),
                const SizedBox(height: 15),
                Text(season, style: AppTypography.cardTitleStyle.copyWith(fontSize: 24)),
                const SizedBox(height: 5),
                Text('Optimal palette matching $tone Skin', style: const TextStyle(color: AppColors.textLight)),
                const Divider(height: 30),
                Text(
                  'Warm Autumn tones are deep, rich, and earthy. Your look is flattered by deep yellows, oranges, and warm olive greens.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDark, height: 1.4),
                )
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Your Color Coordinates', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colors.map((col) {
              return _buildPaletteCircle(col['color'], col['name']);
            }).toList(),
          ),
          const SizedBox(height: 30),
          PremiumButton(
            text: 'See Outfit Recommendations',
            onPressed: () => Navigator.pushNamed(context, '/outfit_recommendations'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaletteCircle(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ==========================================
// 42. OUTFIT RECOMMENDATIONS SCREEN
// ==========================================
class OutfitRecommendationsScreen extends StatelessWidget {
  const OutfitRecommendationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final recs = api.outfitRecs;

    List<Map<String, String>> outfits = [
      {"title": "Camel Trench Coat", "details": "Classic structure matching warm beige skin underlighting.", "tag": "Warm Autumn Season"},
      {"title": "Earthy Olive Linen Pants", "details": "Earthy tone that aligns perfectly with gold hair highlights.", "tag": "Earthy Coordinates"},
      {"title": "Warm Cream Knit Sweater", "details": "Soft look that enhances natural undertone glowing vibes.", "tag": "Cosy Comfort"},
    ];

    if (recs != null && recs['clothing_suggestions'] != null) {
      final list = recs['clothing_suggestions'] as List<dynamic>;
      outfits = list.asMap().entries.map((entry) {
        final idx = entry.key;
        final suggestion = entry.value.toString();
        return {
          "title": suggestion,
          "details": "Best matching apparel for your seasonal undertones.",
          "tag": "AI Suggested ${idx + 1}",
        };
      }).toList();
    }

    return BeautyScaffold(
      title: 'Outfit Recommendations',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top clothing choices matching your color palette:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: outfits.length,
            itemBuilder: (context, idx) {
              final item = outfits[idx];
              return _buildOutfitCard(item['title']!, item['details']!, item['tag']!);
            },
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'Seasonal Suggestions',
            onPressed: () => Navigator.pushNamed(context, '/seasonal_fashion'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(String title, String details, String tag) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
          const SizedBox(height: 6),
          Text(details, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}

// ==========================================
// 43. SEASONAL FASHION SUGGESTIONS SCREEN
// ==========================================
class SeasonalFashionSuggestionsScreen extends StatelessWidget {
  const SeasonalFashionSuggestionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Seasonal suggestions',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Curated selections for the current season:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: [
              _buildProductCard('Knit Sweater', 'Warm Cream Wool', '\$49.00', 'https://images.unsplash.com/photo-1574169208507-84376144848b?w=300&auto=format&fit=crop&q=60'),
              _buildProductCard('Trench Coat', 'Camel Double-breasted', '\$120.00', 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=300&auto=format&fit=crop&q=60'),
            ],
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Try Mix & Match Coordination',
            icon: Icons.cached_rounded,
            onPressed: () => Navigator.pushNamed(context, '/mix_match'),
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
                const SizedBox(height: 4),
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
// 44. MIX & MATCH SCREEN
// ==========================================
class MixMatchScreen extends StatefulWidget {
  const MixMatchScreen({Key? key}) : super(key: key);

  @override
  State<MixMatchScreen> createState() => _MixMatchScreenState();
}

class _MixMatchScreenState extends State<MixMatchScreen> {
  int _selectedTopIdx = 0;
  int _selectedBottomIdx = 0;

  final List<Map<String, String>> _tops = [
    {"name": "Warm Cream Knit", "hex": "#FFFDD0", "price": "\$49"},
    {"name": "Terracotta Blouse", "hex": "#E2725B", "price": "\$38"},
    {"name": "Mustard Silk Camisole", "hex": "#FFDB58", "price": "\$29"},
  ];

  final List<Map<String, String>> _bottoms = [
    {"name": "Olive Linen Trousers", "hex": "#808000", "price": "\$55"},
    {"name": "Camel Utility Cargo", "hex": "#C29A78", "price": "\$64"},
    {"name": "Off-White Denim Skirt", "hex": "#FAF0E6", "price": "\$42"},
  ];

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Mix & Match',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Coordinate tops and bottoms in Warm Autumn colors:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          // Preview Panel
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                const Text('COORDINATE PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                const SizedBox(height: 15),
                // Tops box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(int.parse(_tops[_selectedTopIdx]["hex"]!.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _tops[_selectedTopIdx]["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.link, color: AppColors.primary),
                const SizedBox(height: 10),
                // Bottoms box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(int.parse(_bottoms[_selectedBottomIdx]["hex"]!.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _bottoms[_selectedBottomIdx]["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Selector for tops
          Text('Select Top', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tops.length,
              itemBuilder: (context, idx) {
                final isSelected = idx == _selectedTopIdx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTopIdx = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _tops[idx]["name"]!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Selector for bottoms
          Text('Select Bottom', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _bottoms.length,
              itemBuilder: (context, idx) {
                final isSelected = idx == _selectedBottomIdx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBottomIdx = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _bottoms[idx]["name"]!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Preview Complete Outfit',
            onPressed: () => Navigator.pushNamed(context, '/outfit_preview'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ==========================================
// 45. OUTFIT PREVIEW SCREEN
// ==========================================
class OutfitPreviewScreen extends StatefulWidget {
  const OutfitPreviewScreen({Key? key}) : super(key: key);

  @override
  State<OutfitPreviewScreen> createState() => _OutfitPreviewScreenState();
}

class _OutfitPreviewScreenState extends State<OutfitPreviewScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Elegant Outfit display mockup background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&auto=format&fit=crop&q=60'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const GlassCard(
                  child: Column(
                    children: [
                      Text('Autumn Wool Knit & Camel Trench', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                      SizedBox(height: 6),
                      Text('A rich matching blend of earthy warm autumn tones.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PremiumButton(
                  text: 'Save Outfit to Book',
                  isLoading: _isSaving,
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    final error = await api.saveLook(
                      category: 'outfit',
                      title: 'Autumn Wool Knit & Camel Trench',
                      description: 'A rich matching blend of earthy warm autumn tones.',
                      details: {},
                    );
                    if (mounted) {
                      setState(() => _isSaving = false);
                      if (error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Outfit style bookmarked!')),
                        );
                        Navigator.pushReplacementNamed(context, '/bottom_nav');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Save failed: $error')),
                        );
                      }
                    }
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
