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

  String skinType = "Choose your skin type";
  String allergyType = "Choose your allergy type";
  int age = 18;

  bool _isSaving = false;

  final String baseUrl = "http://10.0.2.2:3000/api/profile";

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
        });
        print("Image selected: ${pickedFile.path}");
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
      _showSnackBar("Failed to pick image", Colors.red);
    }
  }

  Future<void> _saveProfile() async {
    if (_avatarImage == null) {
      _showSnackBar("Please upload an image first", Colors.red);
      return;
    }
    if (skinType == "Choose your skin type") {
      _showSnackBar("Please select your skin type", Colors.red);
      return;
    }
    if (allergyType == "Choose your allergy type") {
      _showSnackBar("Please select your allergy type", Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['skinType'] = skinType;
      request.fields['age'] = age.toString();
      request.fields['allergyType'] = allergyType;

      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        _avatarImage!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar("✅ Profile saved successfully!", Colors.green);
        print("✅ Profile uploaded successfully");
      } else {
        _showSnackBar("❌ Failed to save profile", Colors.red);
        print("❌ Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
      _showSnackBar("Something went wrong", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8BA888),
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
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Main content area with avatar overlapping
            Expanded(
              child: Stack(
                children: [
                  // Content card
                  Container(
                    margin: EdgeInsets.only(top: 60),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F0E3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Back button on content card
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 12),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black87),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 24),
                            child: Column(
                              children: [
                                // Greeting text
                                Text(
                                  'Hello, SARA',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                SizedBox(height: 40),

                                // Skin Type Dropdown
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
                                  onChanged: (value) => setState(() => skinType = value!),
                                ),

                                SizedBox(height: 24),

                                // Allergy Type Dropdown
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
                                  onChanged: (value) => setState(() => allergyType = value!),
                                ),

                                SizedBox(height: 24),

                                // Age Counter
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AGE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove, color: Colors.grey[600]),
                                            onPressed: () {
                                              if (age > 1) {
                                                setState(() => age--);
                                              }
                                            },
                                          ),
                                          Text(
                                            '$age',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add, color: Colors.grey[600]),
                                            onPressed: () {
                                              if (age < 120) {
                                                setState(() => age++);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 40),

                                // Save Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[700],
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSaving
                                        ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
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

                  // Avatar positioned to overlap header and content
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
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
                                backgroundColor: Colors.grey[700],
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
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
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            style: TextStyle(
              color: Colors.grey[600],
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