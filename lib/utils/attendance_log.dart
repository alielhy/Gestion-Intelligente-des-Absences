import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AttendanceRecord {
  final String name;
  final DateTime timestamp;
  final bool isManualEntry;

  AttendanceRecord({
    required this.name,
    required this.timestamp,
    this.isManualEntry = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'isManualEntry': isManualEntry,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      name: map['name'],
      timestamp: DateTime.parse(map['timestamp']),
      isManualEntry: map['isManualEntry'] ?? false,
    );
  }
}

class AttendanceLog with ChangeNotifier {
  static final AttendanceLog _instance = AttendanceLog._internal();
  factory AttendanceLog() => _instance;
  AttendanceLog._internal();

  List<AttendanceRecord> _records = [];
  final String _storageKey = 'attendance_records';

  List<AttendanceRecord> get records => _records;
  
  List<AttendanceRecord> get recognizedStudents => 
      _records.where((r) => r.name.toLowerCase() != 'unknown').toList();
  
  List<AttendanceRecord> get unknownDetections => 
      _records.where((r) => r.name.toLowerCase() == 'unknown').toList();
  
  int get unknownCount => unknownDetections.length;

  Future<void> initialize() async {
    await _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _records = jsonList.map((item) => 
          AttendanceRecord.fromMap(item as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _records.map((record) => record.toMap()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
    notifyListeners();
  }

  Future<void> addRecognitionResult(List<String> names) async {
    final now = DateTime.now();
    for (final name in names) {
      _records.add(AttendanceRecord(
        name: name,
        timestamp: now,
      ));
    }
    await _saveRecords();
  }

  Future<void> addManualEntry(String name) async {
    _records.add(AttendanceRecord(
      name: name,
      timestamp: DateTime.now(),
      isManualEntry: true,
    ));
    await _saveRecords();
  }

  Future<void> clearAllRecords() async {
    _records.clear();
    await _saveRecords();
  }

  Future<void> exportRecords() async {
    // This would be expanded based on your export needs
    final exportData = _records.map((r) => 
        '${r.name},${r.timestamp.toIso8601String()},${r.isManualEntry}').join('\n');
    // In a real app, you'd use a package like 'share_plus' to share this data
    debugPrint(exportData);
  }

  List<AttendanceRecord> filterRecords({
    String? nameFilter,
    DateTime? dateFilter,
    bool? showManualEntries,
  }) {
    return _records.where((record) {
      bool matches = true;
      if (nameFilter != null && nameFilter.isNotEmpty) {
        matches = matches && record.name.toLowerCase().contains(nameFilter.toLowerCase());
      }
      if (dateFilter != null) {
        matches = matches && record.timestamp.year == dateFilter.year &&
                              record.timestamp.month == dateFilter.month &&
                              record.timestamp.day == dateFilter.day;
      }
      if (showManualEntries != null) {
        matches = matches && (record.isManualEntry == showManualEntries);
      }
      return matches;
    }).toList();
  }
}