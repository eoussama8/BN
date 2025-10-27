import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/home_view.dart';
import 'views/contact_view.dart';
import 'views/profile_view.dart';
import 'widgets/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env'); // Always use the asset path
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedNav = "Home";

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
        body: _pages[_selectedNav] ?? const SizedBox(),
        bottomNavigationBar: BottomNavBar(
          selectedNav: _selectedNav,
          onNavChange: _onNavChange,
        ),
      ),
    );
  }
}
