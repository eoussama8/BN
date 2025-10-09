import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/profile_model.dart';

class ProfilePresenter {
  final String baseUrl = "http://10.0.2.2:3000"; // for Android Emulator

  Future<ProfileModel?> createProfile({
    required String skinType,
    required int age,
    required String allergyType,
    required File avatarFile,
  }) async {
    final uri = Uri.parse("$baseUrl/api/profile");
    var request = http.MultipartRequest('POST', uri);

    request.fields['skinType'] = skinType;
    request.fields['age'] = age.toString();
    request.fields['allergyType'] = allergyType;

    request.files.add(await http.MultipartFile.fromPath(
      'avatar',
      avatarFile.path,
      contentType: MediaType('image', 'png'),
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      return ProfileModel.fromJson(
          Map<String, dynamic>.from(await http.Response.fromStream(response).then((r) => http.Response.fromStream(response)).catchError((_) => {})));
    } else {
      print("❌ Error: ${response.statusCode}");
      return null;
    }
  }
}
