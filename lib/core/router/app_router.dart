import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/data/models/content_type.dart';
import 'package:movie_sansaar_mobile/presentation/screens/home/home_screen.dart';
import 'package:movie_sansaar_mobile/presentation/screens/contact/contact_screen.dart';
import 'package:movie_sansaar_mobile/presentation/screens/auth/sign_in_screen.dart';
import 'package:movie_sansaar_mobile/presentation/screens/auth/sign_up_screen.dart';
import 'package:movie_sansaar_mobile/presentation/screens/favorites/favorites_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String contact = '/contact';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String favorites = '/favorites';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        final contentType = settings.arguments as ContentType?;
        return _fadeRoute(
          HomeScreen(initialContent: contentType ?? ContentType.movie),
          settings,
        );
      case contact:
        return _fadeRoute(const ContactScreen(), settings);
      case signUp:
        return _fadeRoute(const SignUpScreen(), settings);
      case signIn:
        return _fadeRoute(const SignInScreen(), settings);
      case favorites:
        return _fadeRoute(const FavoritesScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Page Not Found')),
          ),
        );
    }
  }

  static PageRouteBuilder<dynamic> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
