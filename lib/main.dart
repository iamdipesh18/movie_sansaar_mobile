import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/contact.dart';
import 'screens/sign_up.dart';
import 'screens/sign_in.dart'; // 👈 Add this line

// Models
import 'models/content_type.dart';

// Providers
import 'providers/movie_provider.dart';
import 'providers/series_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/content_type_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        /// 🔌 Dependency Injection for State Management

        // Movie-related logic
        ChangeNotifierProvider(create: (_) => MovieProvider()),

        // Series-related logic
        ChangeNotifierProvider(create: (_) => SeriesProvider()),

        // Toggle logic between Movies and Series
        ChangeNotifierProvider(create: (_) => ContentTypeProvider()),

        // Light/Dark theme logic
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 🌐 Root Widget of the Application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌓 Access the current theme from ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// Set Theme Mode from Provider (Light / Dark)
      themeMode: themeProvider.themeMode,

      /// 🌞 Light Theme Definition
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.light),

      /// 🌙 Dark Theme Definition
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
      ),

      /// 🏁 Initial Route
      initialRoute: '/combined_home',

      /// 🗺️ Route Generator for Navigation (with arguments support)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/combined_home':
            final contentType = settings.arguments as ContentType?;
            return MaterialPageRoute(
              builder: (_) =>
                  HomeScreen(initialContent: contentType ?? ContentType.movie),
            );

          case '/contact':
            return MaterialPageRoute(builder: (_) => const ContactUsScreen());

          case '/signup':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SignUpScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            );

          // Inside your onGenerateRoute:
          case '/signin':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SignInScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            );

          /// 🔁 Add more routes here if needed...

          default:
            // Fallback for unknown routes
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404 - Page Not Found')),
              ),
            );
        }
      },
    );
  }
}
