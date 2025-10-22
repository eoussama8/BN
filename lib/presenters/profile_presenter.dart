import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final String baseUrl;
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ProfilePresenter(this.view) : baseUrl = _getBaseUrl();

  /// Base URL dépend de la plateforme
  static String _getBaseUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:3000/api/profiles"; // Android Emulator
    }
    return "http://localhost:3000/api/profiles"; // Web/Desktop
  }

  /// ================================
  /// 🔒 STOCKAGE CHIFFRÉ DU USER ID
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
  /// 🔄 CHARGER LE PROFIL
  /// ================================
  Future<void> loadProfile({String? userId}) async {
    try {
      // Charger userId depuis le stockage sécurisé si non fourni
      userId ??= await getUserIdSecurely() ?? "default_user";

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

        // Sauvegarde automatique du userId
        await saveUserIdSecurely(userId);
      } else if (response.statusCode == 404) {
        view.updateProfileExistsState(false);
      } else {
        view.showError("Error loading profile: ${response.statusCode}");
      }
    } catch (e) {
      view.showError("Error loading profile: $e");
    }
  }

  /// ================================
  /// 🖼️ PICK IMAGE (avec compression de base)
  /// ================================
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
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
  /// 🗜️ COMPRESSION DES IMAGES
  /// ================================
  Future<File?> _compressFile(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${file.uri.pathSegments.last}";

    final compressedXFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    // Convertir XFile → File
    return compressedXFile != null ? File(compressedXFile.path) : null;
  }

  Future<Uint8List> _compressWebImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final compressed = img.encodeJpg(decoded, quality: 70);
    return Uint8List.fromList(compressed);
  }

  /// ================================
  /// 💾 SAUVEGARDE DU PROFIL
  /// ================================
  Future<void> saveProfile({
    required Profile profile,
    XFile? avatarXFile,
    File? avatarFile,
  }) async {
    if (avatarXFile == null && avatarFile == null) {
      view.showError("Please upload an image first");
      return;
    }

    if (profile.skinType == "Choose your skin type" ||
        profile.skinType.trim().isEmpty) {
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
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['userId'] = profile.userId;
      request.fields['skinType'] = profile.skinType;
      request.fields['age'] = profile.age.toString();
      request.fields['allergyType'] = profile.allergyType;

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
  /// ✏️ MISE À JOUR DU PROFIL
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
      var request = http.MultipartRequest('PUT', Uri.parse(baseUrl));
      request.fields['userId'] = profile.userId;
      request.fields['skinType'] = profile.skinType;
      request.fields['age'] = profile.age.toString();
      request.fields['allergyType'] = profile.allergyType;

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
  /// ❌ SUPPRESSION DU PROFIL
  /// ================================
  Future<void> deleteProfile(String userId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$userId"));
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
