import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  bool _showCinematicOptions = false;

  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onExploreNowPressed() {
    setState(() {
      _showCinematicOptions = true;
    });
    _fadeController.forward(); // start fade-in of buttons immediately
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpg',
              fit: BoxFit.cover,
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Landing with Explore Now button
          if (!_showCinematicOptions)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      backgroundImage: AssetImage('assets/logo.png'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Movie Sansaar',
                      style: textTheme.displaySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dive into the world of movies & series — trailers, ratings & more.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.movie),
                      label: const Text('Explore Now'),
                      onPressed: _onExploreNowPressed,
                    ),
                  ],
                ),
              ),
            ),

          // Cinematic options with Lottie + buttons shown at once
          if (_showCinematicOptions)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.black.withOpacity(0.95)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(color: Colors.transparent),
                    ),

                    // Lottie animation with speed increased (2x speed)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 140,
                      left: 0,
                      right: 0,
                      child: Lottie.asset(
                        'assets/cinema.json',
                        height: 200,
                        fit: BoxFit.contain,
                        repeat: false,
                        animate: true,
                        options: LottieOptions(enableMergePaths: true),
                        frameRate: FrameRate.max,
                      ),
                    ),

                    // Buttons fade in together with animation start
                    FadeTransition(
                      opacity: _fadeController,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 260),
                            _cinematicButton(
                              icon: Icons.local_movies,
                              label: "Enter the World of Movies",
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/home',
                              ),
                            ),
                            const SizedBox(height: 30),
                            _cinematicButton(
                              icon: Icons.tv,
                              label: "Step into Series Realm",
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/series',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 50,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            _showCinematicOptions = false;
                          });
                          _fadeController.reset();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cinematicButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.6),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.redAccent, size: 30),
            const SizedBox(width: 18),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
