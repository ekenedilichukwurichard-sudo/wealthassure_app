import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiService {
  static const String domain = 'quantumxvault.net';
  static const String serverIp = '82.25.96.101';   // <-- YOUR IP HERE

  static http.Client _getClient() {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    return IOClient(client);
  }

  static String _getBaseUrl() {
    // Use IP instead of domain to bypass DNS
    return 'https://$serverIp/api';
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final client = _getClient();
    try {
      final url = Uri.parse('${_getBaseUrl()}/login.php');
      final request = await client.postUrl(url);
      request.headers.add('Content-Type', 'application/json');
      request.headers.add('Host', domain);  // critical: tells server which domain
      request.write(jsonEncode({'username': username, 'password': password}));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final client = _getClient();
    try {
      final url = Uri.parse('${_getBaseUrl()}/profile.php');
      final request = await client.getUrl(url);
      request.headers.add('Authorization', 'Bearer $token');
      request.headers.add('Host', domain);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Profile error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Profile error: $e');
    } finally {
      client.close();
    }
  }
}
