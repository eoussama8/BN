import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/contact_view.dart';
import 'views/profile_view.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Keep track of selected page by name
  String _selectedNav = "Home";

  // Map labels to pages
  final Map<String, Widget> _pages = {
    "Home": const HomeView(),
    "Contact": const ContactView(),
    "Profile": const ProfileView(),
  };

  void _onNavChange(String label) {
    setState(() {
      _selectedNav = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,

        // Show the active page
        body: _pages[_selectedNav] ?? const SizedBox(),

        // Custom BottomNavBar
        bottomNavigationBar: BottomNavBar(
          selectedNav: _selectedNav,
          onNavChange: _onNavChange,
        ),
      ),
    );
  }
}
