import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'submission_service.dart';

class OfflineHandler {
  static Future<void> tryResubmitSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(SubmissionService.offlineKey);

    if (saved != null) {
      final data = jsonDecode(saved);
      final success = await SubmissionService.submitScorecard(data);

      if (success) {
        print("✅ Resubmitted offline data");
        prefs.remove(SubmissionService.offlineKey);
      } else {
        print("❌ Still offline. Will retry later.");
      }
    }
  }
}
