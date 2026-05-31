import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String domain = 'quantumxvault.net';
  static const String serverIp = '82.25.96.101';

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    try {
      final url = Uri(scheme: 'https', host: serverIp, path: '/api/login.php');
      final request = await client.postUrl(url);
      request.headers.add('Content-Type', 'application/json');
      request.headers.add('Host', domain);
      request.write(jsonEncode({'username': username, 'password': password}));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Login failed: ${response.statusCode} - $responseBody');
      }
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    try {
      final url = Uri(scheme: 'https', host: serverIp, path: '/api/profile.php');
      final request = await client.getUrl(url);
      request.headers.add('Authorization', 'Bearer $token');
      request.headers.add('Host', domain);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Profile error: ${response.statusCode} - $responseBody');
      }
    } finally {
      client.close();
    }
  }
}
