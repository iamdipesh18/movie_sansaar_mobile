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
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.redAccent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    'assets/logo.png',
                  ), // Your logo here
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

          // Navigation items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              // Maybe reset to first tab? You can manage that with a callback or provider
            },
          ),
          ListTile(
            leading: const Icon(Icons.movie),
            title: const Text('Movies'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to movies or switch tab as needed
            },
          ),
          ListTile(
            leading: const Icon(Icons.tv),
            title: const Text('TV Series'),
            onTap: () {
              Navigator.pop(context);
              // Navigate accordingly
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to contact page
            },
          ),
          const Divider(),

          // Theme toggle switch moved here
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
            secondary: const Icon(Icons.dark_mode),
          ),

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Sign In'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Sign In screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Sign Up'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Sign Up screen
            },
          ),
        ],
      ),
    );
  }
}
