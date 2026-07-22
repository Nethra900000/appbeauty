import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import '../widgets/showcase_drawer.dart';
import '../services/api_service.dart';

// Helper widget to wrap screens in a beautiful Scaffold with background and showcase drawer access
class BeautyScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const BeautyScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTypography.cardTitleStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: actions ?? [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
            tooltip: "Server Settings",
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_open_rounded, color: AppColors.primary),
              tooltip: "Showcase Navigator",
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          )
        ],
      ),
      endDrawer: const ShowcaseDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.pastelGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: body,
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

// ==========================================
// 1. SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _ScreenPulsePainter extends CustomPainter {
  final double animationVal;
  _ScreenPulsePainter(this.animationVal);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.15 * (1.0 - animationVal))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 120 * animationVal, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding1');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.pastelGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ScreenPulsePainter(_pulseController.value),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.4),
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 30,
                          )
                        ]
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'AI Beauty Genius',
                    style: AppTypography.headlineStyle.copyWith(
                      fontSize: 32,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'INTELLIGENT BEAUTY & STYLING ADVISOR',
                    style: AppTypography.subtitleStyle.copyWith(
                      fontSize: 11,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Floating navigation menu trigger for developers
            Positioned(
              top: 50,
              right: 20,
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.developer_mode, color: AppColors.primary),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: const ShowcaseDrawer(),
    );
  }
}

// ==========================================
// 2. ONBOARDING SCREEN 1
// ==========================================
class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Get Started',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500&auto=format&fit=crop&q=60'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 15,
                          left: 15,
                          child: Row(
                            children: [
                              Icon(Icons.center_focus_weak_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'AI Bio-Scanner',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Precision Scanning',
                    style: AppTypography.headlineStyle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Analyze skin type, facial coordinates, tone, and face shape instantly with deep-learning facial grid scanning.',
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            PremiumButton(
              text: 'Next',
              onPressed: () {
                Navigator.pushNamed(context, '/onboarding2');
              },
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text(
                'Skip Intro',
                style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. ONBOARDING SCREEN 2
// ==========================================
class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Features Overview',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500&auto=format&fit=crop&q=60'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Your Personal Stylist',
                    style: AppTypography.headlineStyle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock personalized makeup palettes, customized daily skincare, custom hairstyles, and seasonal outfit suggestions.',
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            PremiumButton(
              text: 'Get Started',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. LOGIN SCREEN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Login',
      body: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.face_retouching_natural,
            size: 64,
            color: AppColors.primary.withOpacity(0.8),
          ),
          const SizedBox(height: 15),
          Text(
            'Welcome Back',
            style: AppTypography.headlineStyle,
          ),
          Text(
            'Sign in to your beauty profile',
            style: AppTypography.subtitleStyle,
          ),
          const SizedBox(height: 30),
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 25),
                PremiumButton(
                  text: 'Login',
                  isLoading: _isLoading,
                  onPressed: () async {
                    final username = _usernameController.text.trim();
                    final password = _passwordController.text;
                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    final api = Provider.of<ApiService>(context, listen: false);
                    final error = await api.login(username, password);
                    if (mounted) {
                      setState(() => _isLoading = false);
                      if (error == null) {
                        Navigator.pushReplacementNamed(context, '/bottom_nav');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Don\'t have an account? ', style: AppTypography.bodyStyle),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
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

// ==========================================
// 5. SIGNUP SCREEN
// ==========================================
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BeautyScaffold(
      title: 'Sign Up',
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Create Account',
            style: AppTypography.headlineStyle,
          ),
          Text(
            'Set up your personalized profile',
            style: AppTypography.subtitleStyle,
          ),
          const SizedBox(height: 25),
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 25),
                PremiumButton(
                  text: 'Register',
                  isLoading: _isLoading,
                  onPressed: () async {
                    final username = _usernameController.text.trim();
                    final email = _emailController.text.trim();
                    final password = _passwordController.text;
                    if (username.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    final api = Provider.of<ApiService>(context, listen: false);
                    final error = await api.register(username, email, password);
                    if (mounted) {
                      if (error == null) {
                        final loginError = await api.login(username, password);
                        if (mounted) {
                          setState(() => _isLoading = false);
                          if (loginError == null) {
                            Navigator.pushReplacementNamed(context, '/bottom_nav');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registered! But login failed: $loginError')),
                            );
                            Navigator.pop(context);
                          }
                        }
                      } else {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account? ', style: AppTypography.bodyStyle),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
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
