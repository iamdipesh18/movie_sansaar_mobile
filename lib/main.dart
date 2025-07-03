import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/models/content_type.dart';
import 'package:movie_sansaar_mobile/providers/content_type_provider.dart';
import 'package:movie_sansaar_mobile/screens/home_screen.dart'; // Your combined movies/series toggle home screen
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/series_provider.dart';
import 'screens/contact.dart';
import 'screens/sign_up.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Providing movie-related state management
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        // Providing theme management (dark/light mode)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Providing series-related state management
        ChangeNotifierProvider(create: (_) => SeriesProvider()),
        // Providing Movies-Series related statemanagement
        ChangeNotifierProvider(create: (_) => ContentTypeProvider()),


      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current theme mode from ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false, // Disable debug banner
    //   themeMode: themeProvider.themeMode, // Switch between light/dark mode
    //   // Light theme configuration
    //   theme: ThemeData(
    //     primarySwatch: Colors.red,
    //     brightness: Brightness.light,
    //   ),
    //   // Dark theme configuration
    //   darkTheme: ThemeData(
    //     brightness: Brightness.dark,
    //     colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
    //   ),

    //   // Specify initial route explicitly
    //   initialRoute: '/combined_home',

    //   // Define named routes in the app
    //   routes: {
    //     // Main combined home screen with toggle for movies and series
    //     '/combined_home': (context) => const HomeScreen(),

    //     // Other routes for navigation
    //     '/contact': (context) => const ContactScreen(),
    //     '/signup': (context) => const SignupScreen(),
    //   },
    // );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.light),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
      ),
      initialRoute: '/combined_home',

      /// 👇 Replace `routes` with `onGenerateRoute`
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/combined_home':
            final contentType = settings.arguments as ContentType?;
            return MaterialPageRoute(
              builder: (_) =>
                  HomeScreen(initialContent: contentType ?? ContentType.movie),
            );
          case '/contact':
            return MaterialPageRoute(builder: (_) => const ContactScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());

          // case '/watchable':
          //   return MaterialPageRoute(
          //     builder: (_) => const WatchableContentScreen(),

          default:
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
