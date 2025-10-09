import 'package:flutter/material.dart';
import '../utils/contants.dart';
import '../views/settings_view.dart'; // Assurez-vous que le chemin est correct

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Image.asset(AppAssets.logoPng, height: 40),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            // Navigation vers l'écran SettingsView
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsView()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
