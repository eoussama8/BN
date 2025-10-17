import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';

/// Contract interface for the View
abstract class ProfileViewContract {
  void showProfile(Profile profile, String? avatarUrl);
  void showError(String message);
  void showSuccess(String message);
  void showLoading(bool isLoading);
  void updateProfileExistsState(bool exists);
}

/// Presenter for handling Profile API communication
class ProfilePresenter {
  final ProfileViewContract view;
  final String baseUrl;
  final ImagePicker _picker = ImagePicker();

  ProfilePresenter(this.view) : baseUrl = _getBaseUrl();

  static String _getBaseUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:3000/api/profiles";
    }
    return "http://localhost:3000/api/profiles";
  }

  /// Load user profile from the backend
  Future<void> loadProfile({String userId = "default_user"}) async {
    try {
      final uri = Uri.parse("$baseUrl?userId=$userId");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = Profile.fromJson(data);

        final avatarUrl = data['avatar'] != null
            ? "http://localhost:3000/${data['avatar']}"
            : null;

        view.updateProfileExistsState(true);
        view.showProfile(profile, avatarUrl);
      } else if (response.statusCode == 404) {
        view.updateProfileExistsState(false);
      } else {
        view.showError("Error loading profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading profile: $e");
      view.showError("Error loading profile");
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return pickedFile;
      } else {
        view.showError("No image selected");
        return null;
      }
    } catch (e) {
      view.showError("Failed to pick image: $e");
      return null;
    }
  }

  /// Save a new profile
  Future<void> saveProfile({
    required Profile profile,
    XFile? avatarXFile,
    File? avatarFile,
  }) async {
    // Validation
    if (avatarXFile == null) {
      view.showError("Please upload an image first");
      return;
    }
    if (profile.skinType == "Choose your skin type") {
      view.showError("Please select your skin type");
      return;
    }
    if (profile.allergyType == "Choose your allergy type") {
      view.showError("Please select your allergy type");
      return;
    }

    view.showLoading(true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['userId'] = profile.userId;
      request.fields['skinType'] = profile.skinType;
      request.fields['age'] = profile.age.toString();
      request.fields['allergyType'] = profile.allergyType;

      // Attach avatar
      if (kIsWeb) {
        final bytes = await avatarXFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: avatarXFile.name,
        ));
      } else if (avatarFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
        ));
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("Save response: ${response.statusCode} $respStr");

      if (response.statusCode == 200 || response.statusCode == 201) {
        view.showSuccess("✅ Profile saved successfully!");
        await loadProfile(userId: profile.userId);
      } else {
        view.showError("❌ Failed to save profile");
      }
    } catch (e) {
      view.showError("Something went wrong: $e");
      print("Exception: $e");
    } finally {
      view.showLoading(false);
    }
  }

  /// Update an existing profile
  Future<void> updateProfile({
    required Profile profile,
    XFile? avatarXFile,
    File? avatarFile,
  }) async {
    view.showLoading(true);

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(baseUrl));
      request.fields['userId'] = profile.userId;
      request.fields['skinType'] = profile.skinType;
      request.fields['age'] = profile.age.toString();
      request.fields['allergyType'] = profile.allergyType;

      // Attach avatar if changed
      if (kIsWeb && avatarXFile != null) {
        final bytes = await avatarXFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: avatarXFile.name,
        ));
      } else if (avatarFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
        ));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        view.showSuccess("✅ Profile updated successfully!");
        await loadProfile(userId: profile.userId);
      } else {
        view.showError("❌ Failed to update profile");
        print("Error: ${response.statusCode}, $respStr");
      }
    } catch (e) {
      print("Update error: $e");
      view.showError("Error updating profile");
    } finally {
      view.showLoading(false);
    }
  }

  /// Delete a profile by userId
  Future<void> deleteProfile(String userId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$userId"));

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