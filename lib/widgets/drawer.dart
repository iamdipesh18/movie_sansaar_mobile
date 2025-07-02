import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/content_type.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
      child: Column(
        children: [
          // 🔷 Header with logo, app title, tagline, and dark mode toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.black, Colors.grey.shade900]
                    : [Colors.redAccent, Colors.orangeAccent],
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Movie Sansaar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Movies & TV in your pocket',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: 28,
                  ),
                  tooltip: isDarkMode
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                  onPressed: () => themeProvider.toggleTheme(!isDarkMode),
                ),
              ],
            ),
          ),

          // 🔷 Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavTile(
                  context,
                  icon: Icons.home,
                  label: 'Home',
                  routeName: '/combined_home',
                  contentType: ContentType.movie,
                ),
                _buildNavTile(
                  context,
                  icon: Icons.movie_filter_outlined,
                  label: 'Movies',
                  routeName: '/combined_home',
                  contentType: ContentType.movie,
                ),
                _buildNavTile(
                  context,
                  icon: Icons.tv_outlined,
                  label: 'TV Series',
                  routeName: '/series',
                  contentType: ContentType.series,
                ),
                const Divider(),
                _buildNavTile(
                  context,
                  icon: Icons.contact_mail_outlined,
                  label: 'Contact Us',
                  routeName: '/contact',
                ),
                const Divider(),
                _buildNavTile(
                  context,
                  icon: Icons.login,
                  label: 'Sign In',
                  routeName: '/signin',
                ),
                _buildNavTile(
                  context,
                  icon: Icons.app_registration_rounded,
                  label: 'Sign Up',
                  routeName: '/signup',
                ),
              ],
            ),
          ),

          // 🔷 Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '🎬 Movie Sansaar © 2025',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔁 Reusable tile with optional ContentType argument for `/combined_home`
  ListTile _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
    ContentType? contentType,
  }) {
    final isSelected = ModalRoute.of(context)?.settings.name == routeName;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;
    final highlightColor = isDark
        ? Colors.redAccent.withOpacity(0.2)
        : const Color(0xFFF0F0F0);

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(label, style: TextStyle(color: textColor)),
      tileColor: isSelected ? highlightColor : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(context); // Close drawer

        // If already on same route, do nothing
        if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.pushNamed(context, routeName, arguments: contentType);
        }
      },
    );
  }
}
