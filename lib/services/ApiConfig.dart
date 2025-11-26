
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final profileUrl = dotenv.env['PROFILE_URL'] ?? '';
  static final profileApiKey = dotenv.env['API_KEY'] ?? '';

  static final badgesUrl = dotenv.env['BADGES_URL'] ?? '';
}
