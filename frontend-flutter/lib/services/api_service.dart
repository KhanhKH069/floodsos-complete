// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/sos_alert_model.dart';
import '../models/drone_model.dart';

class ApiService {
  static const String openWeatherApiKey = "2e65127e909e178d0af311a81f39948c";

  static String get baseUrl {
    if (kIsWeb ||
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return 'http://127.0.0.1:3002';
    }
    if (Platform.isAndroid) return 'http://10.0.2.2:3002';
    return 'http://127.0.0.1:3002';
  }

  // --- AUTHENTICATION ---

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': username, 'password': password}));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        return {'success': false, 'message': 'Sai tài khoản hoặc mật khẩu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối Server'};
    }
  }

  Future<bool> register(
      String name, String username, String password, String phone,
      {String role = 'user'}) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // --- CHATBOT (FIX LỖI MẤT HÀM NÀY) ---

  Future<String> sendChatMessage(String message) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['reply'] ?? "Lỗi phản hồi.";
      }
    } catch (e) {
      print("Lỗi Chat: $e");
    }
    return "Không thể kết nối tới Server Chat.";
  }

  // --- SOS & DRONE ---

  Future<bool> resolveSOS(String id) async {
    try {
      final res = await http.put(Uri.parse('$baseUrl/api/sos/$id/resolve'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<DroneModel>> getDrones() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/drones'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DroneModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> resetDrones() async {
    try {
      await http.post(Uri.parse('$baseUrl/api/drones/reset'));
    } catch (_) {}
  }

  Future<List<SOSAlertModel>> getSOSAlerts() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/sos'));
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((x) => SOSAlertModel.fromJson(x))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> deleteSOS(String id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/api/sos/$id'));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendTextSOS(Map<String, dynamic> data) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/sos/voice'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendVoiceSOS(Map<String, String> fields, String filePath) async {
    try {
      var req =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/api/sos/voice'));
      req.fields.addAll(fields);
      if (filePath.isNotEmpty)
        req.files.add(await http.MultipartFile.fromPath('audio', filePath));
      var res = await req.send();
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- UTILS ---
  Future<Map<String, dynamic>> getWeather(double lat, double lon) async =>
      {'temp': 0, 'desc': 'Offline'};
  Future<Map<String, dynamic>> getForecast(double lat, double lon) async => {};
  Future<String?> lookupNameByPhone(String p) async => null;
}
