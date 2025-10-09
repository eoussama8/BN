import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _selectedLanguage = "FR";
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? "FR";
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("Langue"),
            _buildLanguageSelector(),

            const SizedBox(height: 20),
            _buildSectionTitle("Thème"),
            _buildThemeSwitch(),

            const SizedBox(height: 20),
            _buildSectionTitle("Notifications"),
            _buildNotificationSwitch(),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await _savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Préférences sauvegardées ✅"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "ENREGISTRER",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: const [
        DropdownMenuItem(value: "FR", child: Text("Français 🇫🇷")),
        DropdownMenuItem(value: "EN", child: Text("English 🇬🇧")),
      ],
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
      },
    );
  }

  Widget _buildThemeSwitch() {
    return SwitchListTile(
      title: const Text("Mode sombre"),
      value: _isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
      },
      activeColor: Colors.green[700],
    );
  }

  Widget _buildNotificationSwitch() {
    return SwitchListTile(
      title: const Text("Activer les notifications"),
      value: _notificationsEnabled,
      onChanged: (value) {
        setState(() {
          _notificationsEnabled = value;
        });
      },
      activeColor: Colors.green[700],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}
