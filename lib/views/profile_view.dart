import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../utils/contants.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  String? _userName; // nom de l’utilisateur dynamique
  String skinType = "Choose your skin type";
  String allergyType = "Choose your allergy type";
  int age = 18;
  bool _isSaving = false;

  final String baseUrl = "http://10.0.2.2:3000/api/profile";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      var response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['name'] ?? '';
          skinType = data['skinType'] ?? skinType;
          allergyType = data['allergyType'] ?? allergyType;
          age = data['age'] ?? age;
          // Optionnel : charger avatar depuis URL si nécessaire
        });
      } else {
        print("Erreur lors du chargement du profil: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur: $e");
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _avatarImage = File(pickedFile.path));
      } else {
        _showSnackBar("No image selected", AppColors.red);
      }
    } catch (e) {
      _showSnackBar("Failed to pick image", AppColors.red);
    }
  }

  Future<void> _saveProfile() async {
    if (_avatarImage == null) {
      _showSnackBar("Please upload an image first", AppColors.red);
      return;
    }
    if (skinType == "Choose your skin type") {
      _showSnackBar("Please select your skin type", AppColors.red);
      return;
    }
    if (allergyType == "Choose your allergy type") {
      _showSnackBar("Please select your allergy type", AppColors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Use _userName or a default userId before full auth
      final String defaultUserId = "default_user";
      request.fields['userId'] = _userName ?? defaultUserId;

      request.fields['name'] = _userName ?? '';
      request.fields['skinType'] = skinType;
      request.fields['age'] = age.toString();
      request.fields['allergyType'] = allergyType;

      request.files.add(
        await http.MultipartFile.fromPath('avatar', _avatarImage!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar("✅ Profile saved successfully!", AppColors.greenDark);
      } else {
        _showSnackBar("❌ Failed to save profile", AppColors.red);
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Something went wrong", AppColors.red);
      print("Exception: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppColors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green2,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 100,
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  // Content card
                  Container(
                    margin: EdgeInsets.only(top: 60),
                    decoration: BoxDecoration(
                      color: AppColors.greenPastel,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.elliptical(40, 30),
                        topRight: Radius.elliptical(40, 30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 12),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: AppColors.greyDark),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                                left: 24, right: 24, top: 40, bottom: 24),
                            child: Column(
                              children: [
                                Text(
                                  'Hello, ${_userName ?? ''}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),

                                SizedBox(height: 40),

                                _buildDropdownField(
                                  label: 'SKIN TYPE',
                                  value: skinType,
                                  items: [
                                    "Choose your skin type",
                                    "Normal",
                                    "Dry",
                                    "Oily",
                                    "Combination"
                                  ],
                                  onChanged: (value) =>
                                      setState(() => skinType = value!),
                                ),

                                SizedBox(height: 24),

                                _buildDropdownField(
                                  label: 'ALLERGY TYPE',
                                  value: allergyType,
                                  items: [
                                    "Choose your allergy type",
                                    "None",
                                    "Pollen",
                                    "Dust",
                                    "Food"
                                  ],
                                  onChanged: (value) =>
                                      setState(() => allergyType = value!),
                                ),

                                SizedBox(height: 24),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AGE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove,
                                                color: AppColors.greyMedium),
                                            onPressed: () {
                                              if (age > 1) setState(() => age--);
                                            },
                                          ),
                                          Text(
                                            '$age',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.greyDark,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add,
                                                color: AppColors.greyMedium),
                                            onPressed: () {
                                              if (age < 120) setState(() => age++);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 40),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.greyDark,
                                      padding:
                                      EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSaving
                                        ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download,
                                            color: AppColors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Save',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.greenPastel,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: _avatarImage != null
                                  ? FileImage(_avatarImage!)
                                  : AssetImage(AppAssets.logoPng) as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImageFromGallery,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.greyDark,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyMedium),
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 14,
            ),
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
