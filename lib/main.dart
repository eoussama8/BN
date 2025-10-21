import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/contact_view.dart';
import 'views/profile_view.dart';
import 'widgets/bottom_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    ContactView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
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
        // ✅ Don’t color the scaffold; let screens define their own background
        backgroundColor: Colors.transparent,

        // ✅ Makes the bottom bar float a bit on top of the body
        extendBody: true,

        // ✅ The active page (takes full screen)
        body: _pages[_selectedIndex],

        // ✅ Custom bottom bar
        bottomNavigationBar: BottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
