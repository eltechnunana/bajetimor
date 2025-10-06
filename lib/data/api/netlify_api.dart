import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// Simple client to call Netlify Function /api/get-post
class NetlifyApi {
  static String _baseUrl() {
    if (kIsWeb) {
      // Use current origin when running on web
      // Avoid importing dart:html directly in mobile builds
      return const String.fromEnvironment('APP_ORIGIN', defaultValue: '');
    }
    // Fallback for non-web; adjust as needed for local testing
    return const String.fromEnvironment('APP_ORIGIN', defaultValue: '');
  }

  static Uri _buildUri(String path, Map<String, String> params) {
    final origin = _baseUrl();
    if (origin.isEmpty) {
      // Relative URL works in browser; for mobile, set APP_ORIGIN via env
      return Uri.parse('$path').replace(queryParameters: params);
    }
    return Uri.parse('$origin$path').replace(queryParameters: params);
  }

  static Future<Map<String, dynamic>> getPost(String id) async {
    final uri = _buildUri('/api/get-post', { 'id': id });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Request failed: ${res.statusCode} ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }
}