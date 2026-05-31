import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiService {
  static const String baseUrl = 'https://quantumxvault.net/api';

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(httpClient);

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(httpClient);

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Profile error: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}
