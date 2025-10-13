import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

abstract class ProfileViewContract {
  void showProfile(Profile profile);
  void showError(String message);
  void showSuccess(String message);
}

class ProfilePresenter {
  final ProfileViewContract view;
  final String baseUrl = "http://10.0.2.2:3000/api/profile"; // make sure it matches your backend port

  ProfilePresenter(this.view);

  // Load profile from backend
  Future<void> loadProfile({String userId = "default_user"}) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl?userId=$userId"));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        view.showProfile(Profile.fromJson(data));
      } else {
        view.showError("Failed to load profile");
      }
    } catch (e) {
      view.showError("Error: $e");
    }
  }

  // Save profile to backend
  Future<void> saveProfile(Profile profile, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Ensure userId is sent (default for testing)
      request.fields['userId'] = profile.userId.isNotEmpty ? profile.userId : "default_user";

      // Add other profile fields
      profile.toFields().forEach((key, value) {
        request.fields[key] = value;
      });

      // Attach avatar image if exists
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', image.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        view.showSuccess("✅ Profile saved successfully!");
      } else {
        view.showError("❌ Failed to save profile");
      }
    } catch (e) {
      view.showError("Error: $e");
    }
  }
}
