import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../utils/contants.dart'; // your logo path

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  String skinType = "Choose Type";
  String allergyType = "Choose Type";
  final TextEditingController ageController = TextEditingController();

  bool _isSaving = false;

  // ✅ Change this for emulator or real device
  final String baseUrl = "http://10.0.2.2:3000/api/profile"; // for Android Emulator
  // Example if you use real phone on same WiFi:
  // final String baseUrl = "http://192.168.1.105:3000/api/profile";

  // Pick image from gallery
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

  // ✅ Save profile (upload to Node backend)
  Future<void> _saveProfile() async {
    if (_avatarImage == null) {
      _showSnackBar("Please upload an image first", Colors.red);
      return;
    }
    if (skinType == "Choose Type") {
      _showSnackBar("Please select your skin type", Colors.red);
      return;
    }
    if (ageController.text.isEmpty) {
      _showSnackBar("Please enter your age", Colors.red);
      return;
    }
    if (allergyType == "Choose Type") {
      _showSnackBar("Please select your allergy type", Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['skinType'] = skinType;
      request.fields['age'] = ageController.text;
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

  // Show SnackBar
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : AssetImage(AppAssets.logoPng) as ImageProvider,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: Text(
                      _avatarImage != null ? "MODIFIER" : "UPLOAD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _avatarImage != null
                          ? Colors.blueAccent
                          : Colors.green[700],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            _buildDropdown(
              "SKIN TYPE :",
              skinType,
              ["Choose Type", "Normal", "Dry", "Oily", "Combination"],
                  (value) => setState(() => skinType = value!),
            ),
            SizedBox(height: 20),

            _buildTextField("AGE :", ageController),
            SizedBox(height: 20),

            _buildDropdown(
              "ALLERGY TYPE :",
              allergyType,
              ["Choose Type", "None", "Pollen", "Dust", "Food"],
                  (value) => setState(() => allergyType = value!),
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  "ENREGISTRER",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            underline: SizedBox(),
            onChanged: onChanged,
            items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
        ),
      ],
    );
  }
}
