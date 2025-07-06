import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubmissionService {
  static const String offlineKey = 'offline_scorecard';
  static const String historyKey = 'submission_history';

  static Future<bool> submitScorecard(Map<String, dynamic> data) async {
    const url = 'https://webhook.site/7eef910f-6ef6-4f69-b6ca-2c451e10da9d';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Submitted to server");
        await _saveToSubmissionHistory(data);
        return true;
      } else {
        print("❌ Submission failed with code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("⚠️ No internet. Saving offline...");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(offlineKey, jsonEncode(data));
      await _saveToSubmissionHistory(data);
      return false;
    }
  }

  // 🔒 Called from anywhere to save to history list
  static Future<void> _saveToSubmissionHistory(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(historyKey) ?? [];
    history.add(jsonEncode(data));
    await prefs.setStringList(historyKey, history);
  }

  // 🔁 Called from main() to try resubmitting offline data
  static Future<void> tryResubmitOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(offlineKey);

    if (saved != null) {
      final json = jsonDecode(saved);
      final success = await submitScorecard(json);
      if (success) {
        await prefs.remove(offlineKey);
      }
    }
  }
}
