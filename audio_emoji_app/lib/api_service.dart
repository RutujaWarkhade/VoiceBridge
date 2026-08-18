import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Base URL of your FastAPI server
  static const String baseUrl = 'http://localhost:8000';
  static const String apiKey = 'supersecret123';

  // Common headers
  static Map<String, String> get headers {
    return {
      'api-key': apiKey,
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  /// -----------------------------
  /// Text Prediction (Text → Emoji)
  /// -----------------------------
  static Future<Map<String, dynamic>> predictText(String text) async {
    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/predict_text'),
        headers: headers,
        body: 'text=${Uri.encodeComponent(text)}',
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result; // ✅ Always returns Map<String, dynamic>
      } else {
        return {"error": "Failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// -----------------------------
  /// Upload Audio (Audio → Text → Emoji)
  /// -----------------------------
  static Future<Map<String, dynamic>> uploadAudio(File audioFile, String language) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_audio'));

      request.files.add(await http.MultipartFile.fromPath(
        'file', // field name must match backend
        audioFile.path,
        contentType: MediaType('audio', 'wav'),
      ));

      request.fields['lang'] = language;
      request.headers['api-key'] = apiKey;

      final response = await request.send().timeout(const Duration(seconds: 15));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        return result; // ✅ Always returns Map<String, dynamic>
      } else {
        return {"error": "Failed with status code ${response.statusCode}"};
      }
    } on TimeoutException {
      return {"error": "Audio upload timeout"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// -----------------------------
  /// Get History
  /// -----------------------------
  static Future<List<dynamic>> getHistory() async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('$baseUrl/history'),
        headers: {'api-key': apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result is List ? result : [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
