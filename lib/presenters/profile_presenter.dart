import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

/// Contract interface for the View
abstract class ProfileViewContract {
  void showProfile(Profile profile);
  void showError(String message);
  void showSuccess(String message);
}

/// Presenter for handling Profile API communication
class ProfilePresenter {
  final ProfileViewContract view;
  final String baseUrl = "http://localhost:3000/api";

  ProfilePresenter(this.view);

  Future<void> loadProfile({String userId = "default_user"}) async {
    try {
      // ✅ use query parameter instead of path
      final response = await http.get(Uri.parse("$baseUrl/profiles?userId=$userId"));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final profile = Profile.fromJson(jsonDecode(response.body));
        view.showProfile(profile);
      } else if (response.statusCode == 404) {
        view.showError("Profile not found");
      } else {
        view.showError("Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      view.showError("Error loading profile: $e");
    }
  }


  /// Save a new profile with optional avatar image
  Future<void> saveProfile(Profile profile, File? image) async {
    try {
      var uri = Uri.parse("$baseUrl/profiles");
      var request = http.MultipartRequest('POST', uri);

      // Add profile fields
      final fields = profile.toFields();
      fields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add avatar file if exists
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', image.path));
      }

      final response = await request.send();

      final respString = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        view.showSuccess("✅ Profile saved successfully!");
      } else {
        view.showError("❌ Failed to save profile: ${response.statusCode}\n$respString");
      }
    } catch (e) {
      view.showError("Error saving profile: $e");
    }
  }

  /// Update an existing profile
  Future<void> updateProfile(Profile profile) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/profiles/${profile.userId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profile.toFields()),
      );

      if (response.statusCode == 200) {
        view.showSuccess("✅ Profile updated successfully!");
      } else if (response.statusCode == 404) {
        view.showError("Profile not found");
      } else {
        view.showError("Failed to update profile: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      view.showError("Error updating profile: $e");
    }
  }

  /// Delete a profile by userId
  Future<void> deleteProfile(String userId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/profiles/$userId"));

      if (response.statusCode == 200) {
        view.showSuccess("✅ Profile deleted successfully!");
      } else if (response.statusCode == 404) {
        view.showError("Profile not found");
      } else {
        view.showError("Failed to delete profile: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      view.showError("Error deleting profile: $e");
    }
  }
}
