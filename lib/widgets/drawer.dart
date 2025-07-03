import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/content_type.dart';
import '../providers/theme_provider.dart';

class ModernDrawer extends StatelessWidget {
  const ModernDrawer({super.key});

  /// Helper to navigate and close drawer
  void _navigateTo(
    BuildContext context,
    String route, {
    ContentType? contentType,
  }) {
    Navigator.pop(context);
    FocusScope.of(context).unfocus();

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route, arguments: contentType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Gradient colors matching header and drawer background
    final gradientColors = isDark
        ? [Colors.black, Colors.grey.shade900]
        : [Colors.redAccent, Colors.orangeAccent];

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          // Detect drag right-to-left inside drawer to close it
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < -10) {
              Navigator.pop(context);
            }
          },
          child: Drawer(
            elevation: 16,
            backgroundColor: Colors.transparent, // So gradient shows fully
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Drawer header with logo, title, and tagline
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/logo.png'),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Movie Sansaar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your movie world',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // The main navigation list with white/black backgrounds and dark/light icons
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

                            _buildTile(
                              context,
                              icon: Icons.contact_mail_outlined,
                              label: 'Contact Us',
                              onTap: () => _navigateTo(context, '/contact'),
                              isDark: isDark,
                            ),
                            _buildTile(
                              context,
                              icon: Icons.app_registration_rounded,
                              label: 'Sign Up',
                              onTap: () => _navigateTo(context, '/signup'),
                              isDark: isDark,
                            ),

                            const Divider(height: 32),

                            // Theme toggle tile
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
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
                                  isDark
                                      ? 'Switch to Light Mode'
                                      : 'Switch to Dark Mode',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
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

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Footer text with subtle color
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '© 2025 Movie Sansaar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black54,
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

  /// Build each navigation tile with proper icon colors and hover effect
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
