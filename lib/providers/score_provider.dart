import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormProvider with ChangeNotifier {
  String stationName = '';
  DateTime? inspectionDate;

  Map<String, List<int>> scores = {};     
  Map<String, String> remarks = {};      

  // Set station name
  void setStationName(String name) {
    stationName = name;
    _autosave();
    notifyListeners();
  }

  // Set inspection date
  void setInspectionDate(DateTime date) {
    inspectionDate = date;
    _autosave();
    notifyListeners();
  }

  // Set score for an activity at given index (coach/section)
  void setScore(String activity, int index, int value) {
    scores.putIfAbsent(activity, () => List.filled(1, -1));
    scores[activity]![index] = value;
    _autosave();
    notifyListeners();
  }

  // Get score for a given activity and index
  int getScore(String activity, int index) {
    return scores[activity]?[index] ?? -1;
  }

  // Set remark
  void setRemark(String activity, String remark) {
    remarks[activity] = remark;
    _autosave();
    notifyListeners();
  }

  // Get remark
  String getRemark(String activity) {
    return remarks[activity] ?? '';
  }

  // Validate that all scores are filled
  bool validateForm() {
    if (stationName.isEmpty || inspectionDate == null) return false;
    for (final entry in scores.entries) {
      if (entry.value.any((score) => score < 0)) return false;
    }
    return true;
  }

  // Save form state locally
  void _autosave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('autosave', jsonEncode(toJson()));
  }

  // Load saved form data from local storage
  Future<void> loadSavedForm() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('autosave');
    if (saved != null) {
      final data = jsonDecode(saved);
      stationName = data['stationName'] ?? '';
      inspectionDate = data['inspectionDate'] != null
          ? DateTime.parse(data['inspectionDate'])
          : null;
      scores = Map<String, List<int>>.from(
          (data['scores'] ?? {}).map((k, v) => MapEntry(k, List<int>.from(v))));
      remarks = Map<String, String>.from(data['remarks'] ?? {});
      notifyListeners();
    }
  }

  // Reset form state
  void reset() {
    stationName = '';
    inspectionDate = null;
    scores.clear();
    remarks.clear();
    notifyListeners();
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'inspectionDate': inspectionDate?.toIso8601String(),
      'scores': scores,
      'remarks': remarks,
    };
  }
}
