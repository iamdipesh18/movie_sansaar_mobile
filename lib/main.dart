import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/screens/series/series_home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/series_provider.dart';
import 'screens/home_page.dart';
import 'screens/contact.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SeriesProvider()),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/series': (context) => const SeriesMainScreen(),
        '/contact': (context) => const ContactScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
