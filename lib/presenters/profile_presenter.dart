import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';

/// ================================
/// VIEW CONTRACT
/// ================================
abstract class ProfileViewContract {
  void showProfile(Profile profile, String? avatarUrl);
  void showError(String message);
  void showSuccess(String message);
  void showLoading(bool isLoading);
  void updateProfileExistsState(bool exists);
}

/// ================================
/// PRESENTER CLASS
/// ================================
class ProfilePresenter {
  final ProfileViewContract view;
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:3000/api/profiles";
  final String apiKey = dotenv.env['API_KEY'] ?? "";


  ProfilePresenter(this.view);

  Map<String, String> get _headers => {
    'x-api-key': apiKey,
  };

  /// ================================
  /// 🔒 Secure storage for userId
  /// ================================
  Future<void> saveUserIdSecurely(String userId) async {
    await _secureStorage.write(key: 'userId', value: userId);
  }

  Future<String?> getUserIdSecurely() async {
    return await _secureStorage.read(key: 'userId');
  }

  Future<void> clearUserData() async {
    await _secureStorage.deleteAll();
  }

  /// ================================
  /// 🔄 Load profile
  /// ================================
  Future<void> loadProfile({String? userId}) async {
    try {
      userId ??= await getUserIdSecurely() ?? "default_user";

      final uri = Uri.parse("$baseUrl?userId=$userId");
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = Profile.fromJson(data);
        final avatarUrl = data['avatar'] != null
            ? "${baseUrl.split('/api')[0]}/${data['avatar']}"
            : null;

        view.updateProfileExistsState(true);
        view.showProfile(profile, avatarUrl);
        await saveUserIdSecurely(userId);
      } else if (response.statusCode == 404) {
        view.updateProfileExistsState(false);
      } else {
        view.showError("Error loading profile: ${response.statusCode}");
        print("Error loading profile: ${response.statusCode}");


      }
    } catch (e) {
      view.showError("Error loading profile: $e");
      print("Error loading profile: $e");


    }
  }

  /// ================================
  /// 🖼️ Pick image
  /// ================================
  Future<XFile?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return pickedFile;
    } catch (e) {
      view.showError("Failed to pick image: $e");
      return null;
    }
  }

  /// ================================
  /// 🗜️ Compress images
  /// ================================
  Future<File?> _compressFile(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${file.uri.pathSegments.last}";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressedFile == null) return null;
    return File(compressedFile.path);
  }


  Future<Uint8List> _compressWebImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 70));
  }

  /// ================================
  /// 💾 Save profile
  /// ================================
  Future<void> saveProfile({
    required Profile profile,
    XFile? avatarXFile,
    File? avatarFile,
  }) async {
    if ((avatarXFile == null && avatarFile == null)) {
      view.showError("Please upload an image first");
      return;
    }
    if (profile.skinType.trim().isEmpty || profile.skinType == "Choose your skin type") {
      view.showError("Please select your skin type");
      return;
    }
    if (profile.age < 13) {
      view.showError("You must be at least 13 years old");
      return;
    }
    const validAllergies = ["None", "Pollen", "Dust", "Food"];
    if (!validAllergies.contains(profile.allergyType)) {
      view.showError("Please select a valid allergy type");
      return;
    }

    view.showLoading(true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl))
        ..headers.addAll(_headers)
        ..fields['userId'] = profile.userId
        ..fields['skinType'] = profile.skinType
        ..fields['age'] = profile.age.toString()
        ..fields['allergyType'] = profile.allergyType;

      if (kIsWeb && avatarXFile != null) {
        final bytes = await _compressWebImage(avatarXFile);
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: avatarXFile.name,
        ));
      } else if (avatarFile != null) {
        final compressed = await _compressFile(avatarFile);
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          compressed?.path ?? avatarFile.path,
        ));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        view.showSuccess("✅ Profile saved successfully!");
        await saveUserIdSecurely(profile.userId);
        await loadProfile(userId: profile.userId);
      } else {
        view.showError("❌ Failed to save profile ($respStr)");
      }
    } catch (e) {
      view.showError("Something went wrong: $e");
    } finally {
      view.showLoading(false);
    }
  }

  /// ================================
  /// ✏️ Update profile
  /// ================================
  Future<void> updateProfile({
    required Profile profile,
    XFile? avatarXFile,
    File? avatarFile,
  }) async {
    if (profile.age < 13) {
      view.showError("You must be at least 13 years old");
      return;
    }
    const validAllergies = ["None", "Pollen", "Dust", "Food"];
    if (!validAllergies.contains(profile.allergyType)) {
      view.showError("Please select a valid allergy type");
      return;
    }

    view.showLoading(true);
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(baseUrl))
        ..headers.addAll(_headers)
        ..fields['userId'] = profile.userId
        ..fields['skinType'] = profile.skinType
        ..fields['age'] = profile.age.toString()
        ..fields['allergyType'] = profile.allergyType;

      if (kIsWeb && avatarXFile != null) {
        final bytes = await _compressWebImage(avatarXFile);
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: avatarXFile.name,
        ));
      } else if (avatarFile != null) {
        final compressed = await _compressFile(avatarFile);
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          compressed?.path ?? avatarFile.path,
        ));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        view.showSuccess("✅ Profile updated successfully!");
        await saveUserIdSecurely(profile.userId);
        await loadProfile(userId: profile.userId);
      } else {
        view.showError("❌ Failed to update profile ($respStr)");
      }
    } catch (e) {
      view.showError("Error updating profile: $e");
    } finally {
      view.showLoading(false);
    }
  }

  /// ================================
  /// ❌ Delete profile
  /// ================================
  Future<void> deleteProfile(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl?userId=$userId"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        await clearUserData();
        view.showSuccess("✅ Profile deleted successfully!");
      } else if (response.statusCode == 404) {
        view.showError("Profile not found");
      } else {
        view.showError(
            "Failed to delete profile: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      view.showError("Error deleting profile: $e");
    }
  }
}
