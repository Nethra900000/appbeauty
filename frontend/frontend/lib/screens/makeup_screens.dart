import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import 'auth_screens.dart';
import '../services/api_service.dart';

// ==========================================
// 26. MAKEUP OVERVIEW SCREEN
// ==========================================
class MakeupOverviewScreen extends StatelessWidget {
  const MakeupOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final tone = api.currentScan?['skin_tone'] ?? api.currentUser?['profile']?['skin_tone'] ?? 'Warm Beige';
    final shape = api.currentScan?['face_shape'] ?? api.currentUser?['profile']?['face_shape'] ?? 'Oval';

    return BeautyScaffold(
      title: 'Makeup Styling',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized makeup guidelines matching your $tone tone and $shape face shape:',
            style: const TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 20),
          _buildCategoryCard(context, 'Lipstick Matching', 'Muted Terracotta & Spice Coral shades.', Icons.brush, '/lipstick_recommendation'),
          _buildCategoryCard(context, 'Foundation Match', 'Matches: Shade 204 Warm Beige.', Icons.face, '/foundation_matching'),
          _buildCategoryCard(context, 'Eye Makeup Styles', 'Winged sunsets and warm blending layers.', Icons.remove_red_eye_outlined, '/eye_makeup'),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Preview Full Makeover',
            icon: Icons.auto_awesome_outlined,
            onPressed: () => Navigator.pushNamed(context, '/makeup_preview'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String desc, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.15), child: Icon(icon, color: AppColors.primary)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 27. LIPSTICK SHADES SCREEN
// ==========================================
class LipstickShadesScreen extends StatefulWidget {
  const LipstickShadesScreen({Key? key}) : super(key: key);

  @override
  State<LipstickShadesScreen> createState() => _LipstickShadesScreenState();
}

class _LipstickShadesScreenState extends State<LipstickShadesScreen> {
  int _selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final tone = api.currentScan?['skin_tone'] ?? api.currentUser?['profile']?['skin_tone'] ?? 'Warm Beige';

    List<Map<String, dynamic>> shades = [
      {"name": "Soft Peach", "color": const Color(0xFFBA2F39), "finish": "Matte finish"},
      {"name": "Rich Crimson", "color": const Color(0xFFA32B32), "finish": "Satin finish"},
      {"name": "Spice Peach", "color": const Color(0xFFD87A68), "finish": "Velvet gloss"},
      {"name": "Sunset Gold", "color": const Color(0xFFC46247), "finish": "Glitter gloss"},
    ];

    if (api.makeupRecs != null && api.makeupRecs!['lipsticks'] != null) {
      final list = api.makeupRecs!['lipsticks'] as List<dynamic>;
      shades = list.map((item) {
        final hexStr = item['color'] as String? ?? '#BA2F39';
        final color = Color(int.parse(hexStr.replaceFirst('#', '0xFF')));
        return {
          "name": item['name'] ?? item['shade'] ?? 'Shade',
          "color": color,
          "finish": "AI Picked finish",
        };
      }).toList();
    }

    if (_selectedIdx >= shades.length) {
      _selectedIdx = 0;
    }

    return BeautyScaffold(
      title: 'Lipstick Recommendations',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top lipstick shades for $tone skin tone:', style: const TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: shades[_selectedIdx]["color"],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
                const SizedBox(height: 15),
                Text(shades[_selectedIdx]["name"], style: AppTypography.cardTitleStyle.copyWith(fontSize: 22)),
                Text(shades[_selectedIdx]["finish"], style: const TextStyle(color: AppColors.textLight)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Select Shade Option', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: shades.length,
              itemBuilder: (context, idx) {
                final shade = shades[idx];
                final isSelected = idx == _selectedIdx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIdx = idx),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: shade["color"],
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.white, width: isSelected ? 4 : 2),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Next: Foundation Matches',
            onPressed: () => Navigator.pushNamed(context, '/foundation_matching'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ==========================================
// 28. FOUNDATION MATCHING SCREEN
// ==========================================
class FoundationMatchingScreen extends StatefulWidget {
  const FoundationMatchingScreen({Key? key}) : super(key: key);

  @override
  State<FoundationMatchingScreen> createState() => _FoundationMatchingScreenState();
}

class _FoundationMatchingScreenState extends State<FoundationMatchingScreen> {
  int _selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final match = api.makeupRecs?['foundation_match'];

    List<Map<String, String>> foundations = [
      {"name": "Warm Beige 204", "hex": "#E8C3A9", "match": "100% Exact Match"},
      {"name": "Soft Sand 206", "hex": "#E2B79A", "match": "94% Match"},
      {"name": "Light Honey 202", "hex": "#EAC8B0", "match": "88% Match"},
    ];

    if (match != null) {
      foundations = [
        {"name": match['suggested_product'] ?? match['shade_name'] ?? 'Suggested Product', "hex": match['hex_code'] ?? '#E8C3A9', "match": "100% Exact Match"},
        {"name": "Alternative Shade A", "hex": "#E2B79A", "match": "90% Match"},
        {"name": "Alternative Shade B", "hex": "#EAC8B0", "match": "80% Match"},
      ];
    }

    return BeautyScaffold(
      title: 'Foundation Matching',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Matched to your face skin pigments:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: foundations.length,
            itemBuilder: (context, idx) {
              final item = foundations[idx];
              final isSelected = idx == _selectedIdx;
              return GestureDetector(
                onTap: () => setState(() => _selectedIdx = idx),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: isSelected ? AppColors.primary : Colors.white.withOpacity(0.5),
                  color: isSelected ? Colors.white.withOpacity(0.6) : null,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(int.parse(item["hex"]!.replaceAll('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["name"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 2),
                            Text(item["match"]!, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textLight, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary)
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Next: Eye Makeup Styles',
            onPressed: () => Navigator.pushNamed(context, '/eye_makeup'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ==========================================
// 29. EYE MAKEUP STYLES SCREEN
// ==========================================
class EyeMakeupScreen extends StatelessWidget {
  const EyeMakeupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Eye Makeup Styles',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended styles for almond eye contouring:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          _buildEyeStyleCard('Winged Sunset Blends', 'Warm peach gradients with a winged liner highlight.', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&auto=format&fit=crop&q=60'),
          _buildEyeStyleCard('Neutral Nude Matte', 'Soft matte brown shadows highlighting crease borders.', 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&auto=format&fit=crop&q=60'),
          _buildEyeStyleCard('Metallic Rose Glam', 'Shimmering rosegold on lids with dense eyelashes.', 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400&auto=format&fit=crop&q=60'),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'Preview Complete Makeover',
            onPressed: () => Navigator.pushNamed(context, '/makeup_preview'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEyeStyleCard(String name, String desc, String imageUrl) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 30. FULL MAKEUP LOOK PREVIEW SCREEN
// ==========================================
class MakeupPreviewScreen extends StatelessWidget {
  const MakeupPreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Styled Preview Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600&auto=format&fit=crop&q=60'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Glass overlay with details
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
                      Text('Dewy Sunset Glam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                      SizedBox(height: 6),
                      Text('Terracotta lips • Rosegold eyelids • Golden glow foundation', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PremiumButton(
                  text: 'Save Look to Book',
                  onPressed: () => Navigator.pushNamed(context, '/save_makeup'),
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
// 31. SAVE MAKEUP LOOK SCREEN
// ==========================================
class SaveMakeupLookScreen extends StatefulWidget {
  const SaveMakeupLookScreen({Key? key}) : super(key: key);

  @override
  State<SaveMakeupLookScreen> createState() => _SaveMakeupLookScreenState();
}

class _SaveMakeupLookScreenState extends State<SaveMakeupLookScreen> {
  final _titleController = TextEditingController(text: 'Dewy Sunset Glam');
  final _descController = TextEditingController(text: 'Terracotta lips • Rosegold eyelids • Golden glow foundation');
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Save Makeup Style',
      body: Column(
        children: [
          const SizedBox(height: 40),
          GlassCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.bookmark_added_outlined, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text('Add to Saved Looks', style: AppTypography.cardTitleStyle),
                const SizedBox(height: 15),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Look Title',
                    hintText: 'e.g. Work Daily Makeup',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add custom notes regarding foundation shades or products used.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 25),
                PremiumButton(
                  text: 'Confirm Save Look',
                  isLoading: _isSaving,
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    final api = Provider.of<ApiService>(context, listen: false);
                    final error = await api.saveLook(
                      category: 'makeup',
                      title: _titleController.text.trim(),
                      description: _descController.text.trim(),
                      details: {},
                    );
                    if (mounted) {
                      setState(() => _isSaving = false);
                      if (error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Look successfully bookmarked!')),
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
