import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/content_type.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart'; // Auth service for login state

class ModernDrawer extends StatelessWidget {
  const ModernDrawer({super.key});

  /// Reusable helper to navigate and close the drawer
  void _navigateTo(
    BuildContext context,
    String route, {
    ContentType? contentType,
  }) {
    Navigator.pop(context); // Close the drawer
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route, arguments: contentType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final isDark = themeProvider.isDarkMode;

    // Background gradient based on theme
    final gradientColors = isDark
        ? [Colors.black, Colors.grey.shade900]
        : [const Color(0xFF8973B3), const Color(0xFF8973B3)];

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < -10) Navigator.pop(context);
          },
          child: Drawer(
            elevation: 16,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ---------- Drawer Header ----------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/logo.png'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Movie Sansaar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.fullName != null &&
                                        user!.fullName!.trim().isNotEmpty
                                    ? user.fullName!
                                    : 'Your movie world',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ---------- Main List ----------
                    Expanded(
                      child: Container(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _buildTile(
                              context,
                              icon: Icons.home_rounded,
                              label: 'Home',
                              onTap: () => _navigateTo(
                                context,
                                '/combined_home',
                                contentType: ContentType.movie,
                              ),
                              isDark: isDark,
                            ),
                            _buildTile(
                              context,
                              icon: Icons.movie_outlined,
                              label: 'Movies',
                              onTap: () => _navigateTo(
                                context,
                                '/combined_home',
                                contentType: ContentType.movie,
                              ),
                              isDark: isDark,
                            ),
                            _buildTile(
                              context,
                              icon: Icons.tv_outlined,
                              label: 'TV Series',
                              onTap: () => _navigateTo(
                                context,
                                '/combined_home',
                                contentType: ContentType.series,
                              ),
                              isDark: isDark,
                            ),

                            const Divider(height: 32),

                            // ---------- Favourites ----------
                            _buildTile(
                              context,
                              icon: Icons.favorite_outline,
                              label: 'Favourites',
                              onTap: () {
                                if (user != null) {
                                  _navigateTo(context, '/favourites');
                                } else {
                                  // Show login prompt
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Login Required'),
                                      content: const Text(
                                        'Please sign in to view your favourites.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _navigateTo(context, '/signin');
                                          },
                                          child: const Text('Sign In'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              isDark: isDark,
                            ),

                            const Divider(height: 32),

                            _buildTile(
                              context,
                              icon: Icons.contact_mail_outlined,
                              label: 'Contact Us',
                              onTap: () => _navigateTo(context, '/contact'),
                              isDark: isDark,
                            ),

                            // ---------- Theme Toggle ----------
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                leading: Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                title: Text(
                                  isDark ? 'Light Mode' : 'Dark Mode',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                trailing: Switch(
                                  value: isDark,
                                  onChanged: themeProvider.toggleTheme,
                                ),
                                hoverColor: isDark
                                    ? Colors.white10
                                    : Colors.black12,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ---------- Divider ----------
                            const Divider(height: 32),

                            // ---------- Log Out (if logged in) or Sign Up (if logged out) ----------
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: user != null
                                  ? _buildTile(
                                      context,
                                      icon: Icons.logout,
                                      label: 'Log Out',
                                      onTap: () async {
                                        await authService.signOut();
                                        Navigator.pop(context);
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/combined_home',
                                        );
                                      },
                                      isDark: isDark,
                                    )
                                  : _buildTile(
                                      context,
                                      icon: Icons.app_registration_rounded,
                                      label: 'Sign Up',
                                      onTap: () =>
                                          _navigateTo(context, '/signup'),
                                      isDark: isDark,
                                    ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // ---------- Footer ----------
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '© 2025 Movie Sansaar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper for drawer tiles
  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: isDark ? Colors.white : Colors.black87),
        title: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        hoverColor: isDark ? Colors.white10 : Colors.black12,
      ),
    );
  }
}
