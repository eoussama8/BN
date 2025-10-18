import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/contact_view.dart';
import 'views/profile_view.dart';
import 'widgets/bottom_bar.dart';
import 'utils/contants.dart'; // For AppColors

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    ContactView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Helper function to get background color per page
  Color _getBackgroundColor(int index) {
    switch (index) {
      case 0: // Home
      case 1: // Contact
        return Colors.white;
      case 2: // Profile
        return AppColors.greenPastel;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: _getBackgroundColor(_selectedIndex), // ✅ dynamic background
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
