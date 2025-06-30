import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const App());
}

class MovieSansaarApp extends StatelessWidget {
  const MovieSansaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Sansaar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text('Hello, Movie Sansaar!'))),
    );
  }
}
