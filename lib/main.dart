import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/contact_view.dart';
import 'views/blog_view.dart';
import 'views/profile_view.dart';
import 'widgets/top_bar.dart';
import 'widgets/bottom_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    ContactView(),
    BlogView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: TopBar(title: _getTitle(_selectedIndex)),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Contact';
      case 2:
        return 'Blog';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }
}
