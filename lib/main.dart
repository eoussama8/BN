import 'package:beaute_naturelle_ia/utils/contants.dart';
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

  Color _getBackgroundColor(int index) {
    switch (index) {
      case 0:
      case 1:
        return Colors.white;
      case 2:
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
        backgroundColor: _getBackgroundColor(_selectedIndex),
        body: SafeArea(
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
