import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import 'auth_screens.dart';
import '../services/api_service.dart';

// ==========================================
// 37. HAIRSTYLE SUGGESTIONS SCREEN
// ==========================================
class HairstyleSuggestionsScreen extends StatelessWidget {
  const HairstyleSuggestionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final shape = api.currentScan?['face_shape'] ?? api.currentUser?['profile']?['face_shape'] ?? 'Oval';
    final recs = api.hairstyleRecs;

    List<Map<String, String>> styles = [
      {"name": "Long Soft Waves", "desc": "Balances oval length with soft side volumes.", "score": "Match Score: 98%"},
      {"name": "Classic Bob with Fringe", "desc": "Accentuates jaw outlines and eyes.", "score": "Match Score: 92%"},
      {"name": "Sleek High Ponytail", "desc": "Highlights facial symmetries and cheekbones.", "score": "Match Score: 87%"},
      {"name": "Textured Pixie Cut", "desc": "Bold, elegant look framing forehead arches.", "score": "Match Score: 82%"},
    ];

    if (recs != null && recs['styles'] != null) {
      final list = recs['styles'] as List<dynamic>;
      styles = list.map<Map<String, String>>((style) {
        return {
          "name": style.toString(),
          "desc": (recs['why'] ?? "Tailored fit matching your $shape facial geometry.").toString(),
          "score": "Match: AI Best",
        };
      }).toList();
    }

    return BeautyScaffold(
      title: 'Hair Suggestions',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommended hairstyles for your $shape face shape:', style: const TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: styles.length,
            itemBuilder: (context, idx) {
              final item = styles[idx];
              return _buildHairStyleTile(context, item['name']!, item['desc']!, item['score']!);
            },
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'Preview Hairstyles on Face',
            icon: Icons.face_retouching_natural_outlined,
            onPressed: () => Navigator.pushNamed(context, '/hairstyle_preview'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHairStyleTile(BuildContext context, String name, String details, String match) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/hairstyle_preview'),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.content_cut_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(details, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                ],
              ),
            ),
            Text(match, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 38. HAIRSTYLE PREVIEW ON FACE (AI OVERLAY)
// ==========================================
class HairstylePreviewScreen extends StatefulWidget {
  const HairstylePreviewScreen({Key? key}) : super(key: key);

  @override
  State<HairstylePreviewScreen> createState() => _HairstylePreviewScreenState();
}

class _HairstylePreviewScreenState extends State<HairstylePreviewScreen> {
  int _selectedHairIdx = 0;
  
  final List<Map<String, String>> _hairOverlays = [
    {"name": "Soft Waves", "url": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&auto=format&fit=crop&q=60"},
    {"name": "Classic Bob", "url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=60"},
    {"name": "High Pony", "url": "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=600&auto=format&fit=crop&q=60"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Live preview simulation with selected hair asset overlay (here mock using different portraits representing hair shapes)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Image.network(
                _hairOverlays[_selectedHairIdx]["url"]!,
                key: ValueKey<int>(_selectedHairIdx),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Hair Selection slider bar
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_hairOverlays.length, (idx) {
                      final isSelected = idx == _selectedHairIdx;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedHairIdx = idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _hairOverlays[idx]["name"]!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                PremiumButton(
                  text: 'Select & Save Hairstyle',
                  onPressed: () => Navigator.pushNamed(context, '/save_hairstyle'),
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
// 39. TRENDING HAIRSTYLES SCREEN
// ==========================================
class TrendingHairstylesScreen extends StatelessWidget {
  const TrendingHairstylesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Trending Hair',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top global hairstyles this month:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          _buildTrendCard('French French Bob', 'Short structured chin-length bob highlighting symmetry.', 'Popularity: +45%'),
          _buildTrendCard('90s Blowout Layers', 'Voluminous layers boosting face frame width.', 'Popularity: +32%'),
          _buildTrendCard('Wispy Bangs Lob', 'Shoulder length cut with soft forehead bangs.', 'Popularity: +28%'),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'Back to suggestions',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, String description, String trends) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
              Text(trends, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}

// ==========================================
// 40. SAVE HAIRSTYLE SCREEN
// ==========================================
class SaveHairstyleScreen extends StatefulWidget {
  const SaveHairstyleScreen({Key? key}) : super(key: key);

  @override
  State<SaveHairstyleScreen> createState() => _SaveHairstyleScreenState();
}

class _SaveHairstyleScreenState extends State<SaveHairstyleScreen> {
  final _controller = TextEditingController(text: 'Summer Soft Waves');
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final shape = api.currentScan?['face_shape'] ?? api.currentUser?['profile']?['face_shape'] ?? 'Oval';

    return BeautyScaffold(
      title: 'Save Hairstyle',
      body: Column(
        children: [
          const SizedBox(height: 40),
          GlassCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.style, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text('Save Style Selection', style: AppTypography.cardTitleStyle),
                const SizedBox(height: 15),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Style Description',
                    hintText: 'e.g. Summer Soft Waves',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 25),
                PremiumButton(
                  text: 'Confirm Save Style',
                  isLoading: _isSaving,
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    final error = await api.saveLook(
                      category: 'hairstyle',
                      title: _controller.text.trim(),
                      description: 'Matched hairstyle for $shape face shape.',
                      details: {},
                    );
                    if (mounted) {
                      setState(() => _isSaving = false);
                      if (error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hairstyle bookmarked!')),
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
