import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with logo and app title
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.redAccent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Movie Sansaar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Explore movies and TV shows',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Home navigation (same as Movies)
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),

          ListTile(
            leading: const Icon(Icons.movie),
            title: const Text('Movies'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/'); // same as Home
            },
          ),

          ListTile(
            leading: const Icon(Icons.tv),
            title: const Text('TV Series'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/series');
            },
          ),

          const Divider(),

          // Contact navigation
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contact');
            },
          ),

          const Divider(),

          // Dark mode toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
            secondary: const Icon(Icons.dark_mode),
          ),

          // Sign In and Sign Up navigation
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Sign In'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/signin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Sign Up'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
    );
  }
}
