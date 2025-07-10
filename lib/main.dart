import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ NEW
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_sansaar_mobile/providers/favourites_provider.dart';
import 'package:movie_sansaar_mobile/screens/favourites_screen.dart';
import 'package:movie_sansaar_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/contact.dart';
import 'screens/sign_up.dart';
import 'screens/sign_in.dart';

// Models
import 'models/content_type.dart';

// Providers
import 'providers/movie_provider.dart';
import 'providers/series_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/content_type_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load .env variables first
  await dotenv.load();

  await Firebase.initializeApp();

  final authService = AuthService();
  final firestore = FirebaseFirestore.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => SeriesProvider()),
        ChangeNotifierProvider(create: (_) => ContentTypeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) =>
              FavoritesProvider(authService: authService, firestore: firestore),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.light),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
      ),
      initialRoute: '/combined_home',
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
          case '/signin':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SignInScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            );
          case '/favourites':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const FavoritesScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            );
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
