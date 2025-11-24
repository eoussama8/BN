import 'dart:io';

import 'package:beaute_naturelle_ia/services/http_override.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'views/profile_view.dart';
import 'widgets/custom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  HttpOverrides.global = MyHttpOverrides();  // ⬅️ IMPORTANT

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int _selectedIndex = 4; // Start directly on Profile tab

  final List<Widget> _pages = const [
    SizedBox(),     // Home
    SizedBox(),     // Recipes
    SizedBox(),     // Challenges
    SizedBox(),     // Favorites
    ProfileView(),  // Profile (your only real screen)
  ];

  void _onNavChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: false,
        backgroundColor: Colors.white,
        body: _pages[_selectedIndex],
        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onNavChange,
        ),
      ),
    );
  }
}
