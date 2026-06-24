import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/content_type.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, String route, {ContentType? type}) {
    Navigator.pop(context);
    FocusScope.of(context).unfocus();
    Navigator.pushReplacementNamed(context, route, arguments: type);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isDark = themeProvider.isDarkMode;

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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/logo.png'),
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
                                user?.fullName?.trim().isNotEmpty == true
                                    ? user!.fullName!
                                    : 'Your movie world',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _tile(context, Icons.home_rounded, 'Home',
                                () => _navigate(context, '/',
                                    type: ContentType.movie),
                                isDark),
                            _tile(context, Icons.movie_outlined, 'Movies',
                                () => _navigate(context, '/',
                                    type: ContentType.movie),
                                isDark),
                            _tile(context, Icons.tv_outlined, 'TV Series',
                                () => _navigate(context, '/',
                                    type: ContentType.series),
                                isDark),
                            const Divider(height: 32),
                            _tile(context, Icons.favorite_outline,
                                'Favorites', () {
                              if (user != null) {
                                _navigate(context, '/favorites');
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Login Required'),
                                    content: const Text(
                                        'Please sign in to view your favorites.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _navigate(context, '/signin');
                                        },
                                        child: const Text('Sign In'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }, isDark),
                            const Divider(height: 32),
                            _tile(context, Icons.contact_mail_outlined,
                                'Contact Us',
                                () => _navigate(context, '/contact'), isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                leading: Icon(
                                  isDark
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
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
                                  onChanged:
                                      themeProvider.toggleTheme,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Divider(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: user != null
                                  ? _tile(
                                      context,
                                      Icons.logout,
                                      'Log Out',
                                      () async {
                                        await auth.signOut();
                                        Navigator.pop(context);
                                        Navigator.pushReplacementNamed(
                                            context, '/');
                                      },
                                      isDark,
                                    )
                                  : _tile(
                                      context,
                                      Icons.app_registration_rounded,
                                      'Sign Up',
                                      () =>
                                          _navigate(context, '/signup'),
                                      isDark,
                                    ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '© 2025 Movie Sansaar',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold),
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

  Widget _tile(BuildContext context, IconData icon, String label,
      VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading:
            Icon(icon, color: isDark ? Colors.white : Colors.black87),
        title: Text(label,
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16)),
        onTap: onTap,
        hoverColor: isDark ? Colors.white10 : Colors.black12,
      ),
    );
  }
}
