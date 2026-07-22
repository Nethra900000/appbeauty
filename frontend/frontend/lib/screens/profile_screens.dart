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
// 46. PROFILE SCREEN
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final user = api.currentUser;
    final profile = user?['profile'];
    final username = user?['username'] ?? 'Sophia Loren';
    final skinType = profile?['skin_type'] ?? 'Combination';
    final skinTone = profile?['skin_tone'] ?? 'Warm Beige';
    final faceShape = profile?['face_shape'] ?? 'Oval';
    final concerns = profile?['skin_concerns'] ?? 'None';
    final skinHealth = api.currentScan != null
        ? '${(api.currentScan!['confidence_score'] ?? 92.0).toInt()}%'
        : '92%';
    final savedCount = api.savedLooks.length.toString();

    return BeautyScaffold(
      title: 'Profile',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username, style: AppTypography.cardTitleStyle.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text('Joined June 2026', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Statistics Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox('Scans', api.currentScan != null ? '1' : '0'),
              _buildStatBox('Saved Looks', savedCount),
              _buildStatBox('Skin Health', skinHealth),
            ],
          ),
          const SizedBox(height: 25),
          Text('My Personal Scorecard', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _buildScoreTile('Skin type', skinType),
                _buildScoreTile('Skin tone', skinTone),
                _buildScoreTile('Face shape', faceShape),
                _buildScoreTile('Concerns', concerns),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'Edit Preferences',
            onPressed: () => Navigator.pushNamed(context, '/edit_preferences'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            child: Center(child: Text('Settings', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold))),
          )
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return GlassCard(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildScoreTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDark)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ==========================================
// 47. SAVED LOOKS GALLERY SCREEN
// ==========================================
class SavedLooksScreen extends StatelessWidget {
  const SavedLooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final savedLooks = api.savedLooks;

    final makeupLooks = savedLooks.where((l) => l['category'] == 'makeup').toList();
    final hairstyleLooks = savedLooks.where((l) => l['category'] == 'hairstyle').toList();
    final outfitLooks = savedLooks.where((l) => l['category'] == 'outfit').toList();

    return BeautyScaffold(
      title: 'Saved Looks Book',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your bookmarked makeup styles, hairstyles, and outfits:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 20),
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textLight,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Makeup'),
                    Tab(text: 'Hairstyles'),
                    Tab(text: 'Outfits'),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 340,
                  child: TabBarView(
                    children: [
                      _buildGalleryList(context, 'Makeup', makeupLooks),
                      _buildGalleryList(context, 'Hairstyles', hairstyleLooks),
                      _buildGalleryList(context, 'Outfits', outfitLooks),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryList(BuildContext context, String category, List<dynamic> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('No saved $category looks yet.', style: const TextStyle(color: AppColors.textLight)),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final look = items[idx];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(look['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(look['description'] ?? '$category Saved Look', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  final api = Provider.of<ApiService>(context, listen: false);
                  final err = await api.deleteLook(look['id']);
                  if (context.mounted) {
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Look removed.')));
                    }
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 48. SETTINGS SCREEN
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _faceDataShare = true;
  late TextEditingController _serverController;

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);
    _serverController = TextEditingController(text: api.baseUrl);
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Settings',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferences', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(color: AppColors.textDark)),
                  value: _darkMode,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
                SwitchListTile(
                  title: const Text('Anonymized Face Mesh Sharing', style: TextStyle(color: AppColors.textDark)),
                  subtitle: const Text('Helps improve classification accuracy', style: TextStyle(fontSize: 11)),
                  value: _faceDataShare,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _faceDataShare = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Server Configuration', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _serverController,
                  decoration: const InputDecoration(
                    labelText: 'Backend Flask Server IP',
                    hintText: 'e.g. http://10.0.2.2:5000',
                  ),
                ),
                const SizedBox(height: 15),
                PremiumButton(
                  text: 'Save Server Config',
                  onPressed: () {
                    final api = Provider.of<ApiService>(context, listen: false);
                    api.setBaseUrl(_serverController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Server endpoint configured to ${_serverController.text}')),
                    );
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Go to Premium Plan',
            gradientColors: AppColors.goldPremiumGradient,
            icon: Icons.star,
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ==========================================
// 49. EDIT PREFERENCES SCREEN
// ==========================================
class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  final Map<String, bool> _concerns = {
    "Redness / Sensitive Flakes": false,
    "Excess Sebum / Acne breakouts": false,
    "Fine Lines / Wrinkling": false,
    "Dark spots / Pigmentation": false,
  };
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);
    final existingConcerns = api.currentUser?['profile']?['skin_concerns'] ?? 'None';
    if (existingConcerns != 'None') {
      final list = existingConcerns.split(', ');
      for (var concern in list) {
        if (_concerns.containsKey(concern)) {
          _concerns[concern] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Concerns & Style',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tick skin concerns to refine AI skincare targets:', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 15),
          GlassCard(
            child: Column(
              children: _concerns.keys.map((concern) {
                return CheckboxListTile(
                  title: Text(concern, style: const TextStyle(color: AppColors.textDark, fontSize: 14)),
                  value: _concerns[concern],
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _concerns[concern] = val ?? false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 25),
          PremiumButton(
            text: 'Save User Preferences',
            isLoading: _isSaving,
            onPressed: () async {
              setState(() => _isSaving = true);
              final activeConcerns = _concerns.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList();
              final concernsStr = activeConcerns.isEmpty ? 'None' : activeConcerns.join(', ');

              final api = Provider.of<ApiService>(context, listen: false);
              final profile = api.currentUser?['profile'] ?? {};
              final error = await api.updateProfilePreferences(
                skinType: profile['skin_type'] ?? 'Combination',
                skinTone: profile['skin_tone'] ?? 'Fair',
                faceShape: profile['face_shape'] ?? 'Oval',
                concerns: concernsStr,
              );

              if (mounted) {
                setState(() => _isSaving = false);
                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferences updated successfully.')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $error')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ==========================================
// 50. SUBSCRIPTION / PREMIUM SCREEN
// ==========================================
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Upgrade Premium',
      body: Column(
        children: [
          const SizedBox(height: 20),
          GlassCard(
            borderColor: AppColors.goldPremiumGradient.first.withOpacity(0.6),
            color: Colors.white.withOpacity(0.45),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.goldPremiumGradient),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PRO ACCESS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 20),
                Text('AI Beauty Pro', style: AppTypography.cardTitleStyle.copyWith(fontSize: 26)),
                const SizedBox(height: 12),
                Text('\$9.99 / Month', style: GoogleFonts.firaMono(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.textDark)),
                const Divider(height: 35),
                _buildFeatureRow('Unlimited real-time face scans'),
                _buildFeatureRow('Access 3D AR hair preview meshes'),
                _buildFeatureRow('Advanced cosmetic product price tracking'),
                _buildFeatureRow('Priority chat with AI Beauty Assistant'),
                const SizedBox(height: 30),
                PremiumButton(
                  text: 'Unlock Pro access',
                  gradientColors: AppColors.goldPremiumGradient,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Welcome to AI Beauty Genius Pro!')),
                    );
                    Navigator.pushReplacementNamed(context, '/bottom_nav');
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.star_purple500, color: Color(0xFFFDA085), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textDark, fontSize: 13))),
        ],
      ),
    );
  }
}
