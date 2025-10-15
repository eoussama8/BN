import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../utils/contants.dart'; // Keep your AppColors, AppAssets here

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _avatarImageFile;
  XFile? _avatarImageXFile;
  final ImagePicker _picker = ImagePicker();

  String? _userName;
  String skinType = "Choose your skin type";
  String allergyType = "Choose your allergy type";
  int age = 18;
  bool _isSaving = false;
  String? avatarUrl;
  bool _isExistingProfile = false;
  late final String baseUrl;

  @override
  void initState() {
    super.initState();
    // Fix for Android emulator (localhost redirect)
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = "http://10.0.2.2:3000/api/profiles/";
    } else {
      baseUrl = "http://localhost:3000/api/profiles/";
    }
    _loadUserProfile();
  }
  Future<void> _loadUserProfile() async {
    try {
      const userId = "default_user";
      final uri = Uri.parse("$baseUrl?userId=$userId");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _isExistingProfile = true; // ✅ profile exists
          _userName = data['userId'] ?? '';
          skinType = data['skinType'] ?? "Choose your skin type";
          allergyType = data['allergyType'] ?? "Choose your allergy type";
          age = data['age'] ?? 18;
          avatarUrl = data['avatar'] != null
              ? "http://localhost:3000/${data['avatar']}"
              : null;
        });
      } else if (response.statusCode == 404) {
        setState(() => _isExistingProfile = false); // ✅ no profile
      } else {
        _showSnackBar("Error loading profile: ${response.statusCode}", AppColors.red);
      }
    } catch (e) {
      print("Error loading profile: $e");
      _showSnackBar("Error loading profile", AppColors.red);
    }
  }


  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _avatarImageXFile = pickedFile;
          if (!kIsWeb) {
            _avatarImageFile = File(pickedFile.path);
          }
        });
      } else {
        _showSnackBar("No image selected", AppColors.red);
      }
    } catch (e) {
      _showSnackBar("Failed to pick image: $e", AppColors.red);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(baseUrl));
      request.fields['userId'] = _userName ?? "default_user";
      request.fields['skinType'] = skinType;
      request.fields['age'] = age.toString();
      request.fields['allergyType'] = allergyType;

      // Attach avatar
      if (kIsWeb) {
        if (_avatarImageXFile != null) {
          final bytes = await _avatarImageXFile!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'avatar',
            bytes,
            filename: _avatarImageXFile!.name,
          ));
        }
      } else if (_avatarImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', _avatarImageFile!.path));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _showSnackBar("✅ Profile updated successfully!", AppColors.greenDark);
        _loadUserProfile(); // refresh UI
      } else {
        _showSnackBar("❌ Failed to update profile", AppColors.red);
        print("Error: ${response.statusCode}, $respStr");
      }
    } catch (e) {
      print("Update error: $e");
      _showSnackBar("Error updating profile", AppColors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }


  Future<void> _saveProfile() async {
    if (_avatarImageXFile == null && avatarUrl == null) {
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
      request.fields['userId'] = _userName ?? "default_user";
      request.fields['skinType'] = skinType;
      request.fields['age'] = age.toString();
      request.fields['allergyType'] = allergyType;

      // Attach avatar
      if (_avatarImageXFile != null) {
        if (kIsWeb) {
          final bytes = await _avatarImageXFile!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'avatar',
            bytes,
            filename: _avatarImageXFile!.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'avatar',
            _avatarImageFile!.path,
          ));
        }
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("Save response: ${response.statusCode} $respStr");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("✅ Profile saved successfully!", AppColors.greenDark);
        await _loadUserProfile(); // Refresh UI with new data
      } else {
        _showSnackBar("❌ Failed to save profile", AppColors.red);
      }
    } catch (e) {
      _showSnackBar("Something went wrong: $e", AppColors.red);
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
                                        borderRadius:
                                        BorderRadius.circular(12),
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
                                              if (age > 1)
                                                setState(() => age--);
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
                                              if (age < 120)
                                                setState(() => age++);
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
                                    onPressed: _isSaving
                                        ? null
                                        : _isExistingProfile
                                        ? _updateProfile
                                        : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.greyDark,
                                      padding:
                                      EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
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
                                      _isExistingProfile ? 'Modify' : 'Save',
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
                  // Avatar section
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
                              backgroundImage: _avatarImageXFile != null
                                  ? (kIsWeb
                                  ? NetworkImage(_avatarImageXFile!.path)
                                  : FileImage(_avatarImageFile!) as ImageProvider)
                                  : (avatarUrl != null
                                  ? NetworkImage(avatarUrl!)
                                  : const AssetImage("assets/logo.png")),

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
                                child: Icon(Icons.camera_alt,
                                    color: AppColors.white, size: 20),
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
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black)),
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
            icon:
            Icon(Icons.keyboard_arrow_down, color: AppColors.greyMedium),
            style: TextStyle(color: AppColors.greyDark, fontSize: 14),
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
