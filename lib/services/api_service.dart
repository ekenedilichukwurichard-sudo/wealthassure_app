import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

class ApiService {
  static const String domain = 'quantumxvault.net';
  static const String serverIp = '82.25.96.101';

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://$serverIp/api',
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      headers: {'Host': domain},
    ));
    // Bypass SSL certificate errors
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
    return dio;
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final dio = _createDio();
    try {
      final response = await dio.post(
        '/login.php',
        data: {'username': username, 'password': password},
        options: Options(contentType: 'application/json'),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final dio = _createDio();
    try {
      final response = await dio.get(
        '/profile.php',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Profile error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Profile error: $e');
    }
  }
}
