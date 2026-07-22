import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
// import '../widgets/showcase_drawer.dart';
import 'auth_screens.dart';
import '../services/api_service.dart';
import 'profile_screens.dart';

// ==========================================
// 6. HOME DASHBOARD
// ==========================================
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final username = api.currentUser?['username'] ?? 'Beautiful';

    return BeautyScaffold(
      title: 'AI Beauty Genius',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $username!',
                    style: AppTypography.headlineStyle.copyWith(fontSize: 24),
                  ),
                  Text(
                    'Let\'s check your skin health today.',
                    style: AppTypography.subtitleStyle,
                  ),
                ],
              ),
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Main CTA Card
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Intelligent Scan',
                      style: AppTypography.cardTitleStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Instantly detect skin type, tone, face shape, and unlock customized makeover styles using your phone camera.',
                  style: TextStyle(height: 1.4, color: AppColors.textDark),
                ),
                const SizedBox(height: 20),
                PremiumButton(
                  text: 'Scan My Face Now',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () {
                    Navigator.pushNamed(context, '/camera_permission');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Quick Analysis Preview', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          // Horizontal scrolling previews of results
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildQuickCard(
                  context,
                  Icons.opacity,
                  'Skin Type',
                  api.currentScan?['skin_type'] ?? api.currentUser?['profile']?['skin_type'] ?? 'Combination',
                  '/skin_type_result',
                ),
                _buildQuickCard(
                  context,
                  Icons.palette,
                  'Skin Tone',
                  api.currentScan?['skin_tone'] ?? api.currentUser?['profile']?['skin_tone'] ?? 'Warm Beige',
                  '/skin_tone_result',
                ),
                _buildQuickCard(
                  context,
                  Icons.face,
                  'Face Shape',
                  (api.currentScan?['face_shape'] ?? api.currentUser?['profile']?['face_shape'] ?? 'Oval') + ' Shape',
                  '/face_shape_result',
                ),
                _buildQuickCard(
                  context,
                  Icons.auto_awesome,
                  'Makeup Match',
                  api.makeupRecs?['makeup_style'] ?? 'Dewy Peach',
                  '/makeup_overview',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickCard(
    BuildContext context,
    IconData icon,
    String title,
    String val,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: GlassCard(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const Spacer(),
            Text(title, style: AppTypography.labelStyle.copyWith(fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              val,
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. BOTTOM NAVIGATION WRAPPER
// ==========================================
class BottomNavigationUI extends StatefulWidget {
  const BottomNavigationUI({Key? key}) : super(key: key);

  @override
  State<BottomNavigationUI> createState() => _BottomNavigationUIState();
}

class _BottomNavigationUIState extends State<BottomNavigationUI> {
  int _currentIndex = 0;

  // Placeholder pages mapping
  final List<Widget> _pages = [
    const HomeDashboardScreen(),
    const Center(child: Text("Camera Scanner")), // Stub for Scan flow trigger
    const SearchScreen(),
    const SavedLooksScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // If scanning is pressed (index 1), let's push route to Scan flow, and don't change main tab
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 1 ? 0 : _currentIndex, // Avoid blank scans
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, '/camera_permission');
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight.withOpacity(0.6),
          selectedLabelStyle: AppTypography.labelStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTypography.labelStyle,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: 'Scan',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 8. NOTIFICATIONS SCREEN
// ==========================================
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Notifications',
      body: Column(
        children: [
          _buildNotificationTile(
            Icons.spa_outlined,
            'Daily Skincare Routine Reminder',
            'Time for your Evening hydration locks! Click to open routine guide.',
            '10 mins ago',
          ),
          _buildNotificationTile(
            Icons.palette_outlined,
            'New Lipstick Match Found',
            'Your matched tone "Warm Beige" has 3 trending coral matches this season.',
            '2 hours ago',
          ),
          _buildNotificationTile(
            Icons.star_purple500_outlined,
            'Premium Active',
            'Welcome to premium! You now have unrestricted access to hairstyle mesh models.',
            '1 day ago',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    IconData icon,
    String title,
    String body,
    String time,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              body,
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 9. SEARCH SCREEN
// ==========================================
class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Explore looks',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search makeup styles, hairstyles, outfits...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Trending Categories', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildFilterChip('Dewy Makeup'),
              _buildFilterChip('Glass Skin'),
              _buildFilterChip('Classic Bobs'),
              _buildFilterChip('Summer Color Palette'),
              _buildFilterChip('Nude Lipsticks'),
              _buildFilterChip('Oval Hairstyles'),
            ],
          ),
          const SizedBox(height: 25),
          Text('Popular Looks', style: AppTypography.cardTitleStyle),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: [
              _buildLookCard(
                'Warm Sunset Glam',
                'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=300&auto=format&fit=crop&q=60',
              ),
              _buildLookCard(
                'Minimalist Clean Look',
                'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=300&auto=format&fit=crop&q=60',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white.withOpacity(0.5),
      labelStyle: const TextStyle(color: AppColors.textDark),
      side: BorderSide(color: Colors.white.withOpacity(0.8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildLookCard(String title, String imageUrl) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 10. VOICE ASSISTANT / AI CHAT
// ==========================================
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final List<Map<String, String>> _messages = [
    {
      "sender": "bot",
      "text":
          "Hi, I am your Beauty Genius Assistant! Ask me anything about your skin tone, matched lipsticks, or style tips.",
    },
  ];
  final _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'AI Chat Advisor',
      body: Column(
        children: [
          // Chat messages view
          Container(
            height: 380,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.primary.withOpacity(0.8)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.6)),
                    ),
                    child: Text(
                      msg["text"] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Ask about lipstick, hairstyles...',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_chatController.text.trim().isEmpty) return;
                    setState(() {
                      _messages.add({
                        "sender": "user",
                        "text": _chatController.text,
                      });
                      final query = _chatController.text.toLowerCase();
                      _chatController.clear();

                      // Auto bot responses matching the context
                      Timer(const Duration(milliseconds: 600), () {
                        setState(() {
                          if (query.contains('lipstick') ||
                              query.contains('makeup')) {
                            _messages.add({
                              "sender": "bot",
                              "text":
                                  "Based on your Warm Beige tone, I highly recommend our Spiced Peach lipstick shade!",
                            });
                          } else if (query.contains('hair') ||
                              query.contains('cut')) {
                            _messages.add({
                              "sender": "bot",
                              "text":
                                  "Since you have an Oval face shape, you can try Long Soft Waves or a Classic Bob.",
                            });
                          } else {
                            _messages.add({
                              "sender": "bot",
                              "text":
                                  "Interesting query! I can analyze that. Try asking 'What skincare products match dry skin?'.",
                            });
                          }
                        });
                      });
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
