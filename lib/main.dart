import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/http_service.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/movie_provider.dart';
import 'presentation/providers/series_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  HttpService.instance.init();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => SeriesProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(firestore: firestore),
        ),
      ],
      child: const MovieSansaarApp(),
    ),
  );
}
