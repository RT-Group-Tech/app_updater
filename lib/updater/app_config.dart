import 'dart:convert';

import 'package:http/http.dart' as http;

class AppConfig {
  static double? currentVersion = 1.2;

  Future<Map<String, dynamic>> loadJsonGithubAppInfos() async {
    final response = await http.read(Uri.parse("  "));
    return jsonDecode(response);
  }
}
