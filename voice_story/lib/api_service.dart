import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // NEW: Required for downloading
import 'login.dart';

class ApiService {
  // ==========================================
  // SINGLETON PATTERN
  // ==========================================
  static final ApiService instance = ApiService._internal();
  ApiService._internal();
  factory ApiService() => instance;

  // UPDATED: Standardizing on your current working IP
  static const String baseUrl = "http://192.168.1.104:8000";
  // ==========================================
  // Fetch Translation History
  // ==========================================
  Future<List<dynamic>> getHistory(String username) async {
    try {
      final url = Uri.parse("$baseUrl/history").replace(
          queryParameters: {"username": username}
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // utf8.decode ensures characters in history display correctly
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['history'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint("❌ History Fetch Error: $e");
      return [];
    }
  }

  // ==========================================
  // AUTH LOGIC: handleAuth (Used by Login.dart)
  // ==========================================
  Future<Map<String, dynamic>> handleAuth(String username, {bool isSignup = false}) async {
    if (isSignup) {
      return await registerUser(username);
    } else {
      return await authenticateUser(username);
    }
  }

  Future<Map<String, dynamic>> authenticateUser(String email) async {
    final url = Uri.parse("$baseUrl/signin").replace(queryParameters: {"username": email});
    try {
      final response = await http.post(url).timeout(const Duration(seconds: 10));
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', email);
        return decodedBody;
      } else {
        return {"status": "error", "message": decodedBody['detail'] ?? "Invalid user"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection timed out. Check Firewall!"};
    }
  }

  Future<Map<String, dynamic>> registerUser(String email) async {
    final url = Uri.parse("$baseUrl/signup").replace(queryParameters: {"username": email});
    try {
      final response = await http.post(url).timeout(const Duration(seconds: 10));
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return decodedBody;
      } else {
        return {"status": "error", "message": decodedBody['detail'] ?? "Account exists"};
      }
    } catch (e) {
      return {"status": "error", "message": "Cannot connect to server."};
    }
  }

  // ==========================================
  // STT: Speech to Text (Multi-part upload)
  // ==========================================
  Future<String?> transcribeAudio(String email, String filePath, String lang) async {
    try {
      File audioFile = File(filePath);
      if (!await audioFile.exists()) return null;

      var uri = Uri.parse("$baseUrl/transcribe").replace(queryParameters: {
        "username": email,
        "lang": lang,
      });

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['text'];
      }
      return null;
    } catch (e) {
      debugPrint("❌ STT Error: $e");
      return null;
    }
  }

  // ==========================================
  // TTS: Text to Speech URL Generator
  // ==========================================
  Future<String?> generateSpeech(String text, String lang) async {
    try {
      final String encodedText = Uri.encodeComponent(text);
      return "$baseUrl/tts?text=$encodedText&lang=$lang";
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // PROFILE LOGIC
  // ==========================================
  Future<Map<String, dynamic>?> getProfile(String username) async {
    try {
      final url = Uri.parse("$baseUrl/profile").replace(queryParameters: {"username": username});
      final response = await http.get(url);
      if (response.statusCode == 200) return json.decode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile(String username, String name, String password, String gender, File? photo) async {
    try {
      var uri = Uri.parse("$baseUrl/update_profile");
      var request = http.MultipartRequest('POST', uri);

      request.fields['username'] = username;
      request.fields['name'] = name;
      request.fields['password'] = password;
      request.fields['gender'] = gender;

      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath('file', photo.path));
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // NEW: DOWNLOAD AUDIO TO DEVICE
  // ==========================================
  Future<String?> downloadAudio(String relativePath) async {
    try {
      // Ensure we have the full URL
      final urlStr = relativePath.startsWith('http') ? relativePath : "$baseUrl/$relativePath";
      final url = Uri.parse(urlStr);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Directory? dir;
        // Standardize saving to the public Downloads folder on Android
        if (Platform.isAndroid) {
          dir = Directory('/storage/emulated/0/Download');
          if (!await dir.exists()) dir = await getExternalStorageDirectory();
        } else {
          dir = await getApplicationDocumentsDirectory(); // iOS fallback
        }

        // Determine if it's a WAV or MP3
        final extension = relativePath.endsWith('.wav') ? '.wav' : '.mp3';
        final fileName = "VoiceStory_${DateTime.now().millisecondsSinceEpoch}$extension";
        final file = File('${dir!.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);
        return file.path; // Return the path on success
      }
      return null;
    } catch (e) {
      debugPrint("❌ Download Error: $e");
      return null;
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');

      if (!context.mounted) return;

      // THE FIX: Use MaterialPageRoute instead of a named route
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
            (route) => false, // This destroys all previous screens so the user can't hit "back" to enter the app
      );

      debugPrint("👋 User logged out successfully");
    } catch (e) {
      debugPrint("❌ Logout Error: $e");
    }
  }
}