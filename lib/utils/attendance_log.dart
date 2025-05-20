import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Data model for an attendance record
class AttendanceRecord {
  final String name;
  final DateTime timestamp;
  final bool isManualEntry;
  final bool isAbsent;

  AttendanceRecord({
    required this.name,
    required this.timestamp,
    this.isManualEntry = false,
    this.isAbsent = false,
  });

  /// Converts the record to a Map for serialization
  Map<String, dynamic> toMap() => {
        'name': name,
        'timestamp': timestamp.toIso8601String(),
        'isManualEntry': isManualEntry,
        'isAbsent': isAbsent,
      };

  /// Creates a record from a Map (deserialization)
  factory AttendanceRecord.fromMap(Map<String, dynamic> map) => AttendanceRecord(
        name: map['name'],
        timestamp: DateTime.parse(map['timestamp']),
        isManualEntry: map['isManualEntry'] ?? false,
        isAbsent: map['isAbsent'] ?? false,
      );
}

/// Singleton class managing attendance data with change notification
class AttendanceLog with ChangeNotifier {
  // Singleton instance
  static final AttendanceLog _instance = AttendanceLog._internal();
  factory AttendanceLog() => _instance;
  AttendanceLog._internal();

  // Private state
  List<AttendanceRecord> _records = [];
  List<String> _studentList = [];
  static const String _storageKey = 'attendance_records';

  // Public getters
  List<AttendanceRecord> get records => _records;
  List<String> get studentList => _studentList;
  List<AttendanceRecord> get recognizedStudents =>
      _records.where((r) => _normalizeName(r.name) != 'unknown').toList();
  List<AttendanceRecord> get unknownDetections =>
      _records.where((r) => _normalizeName(r.name) == 'unknown').toList();
  int get unknownCount => unknownDetections.length;
  List<String> get presentStudents => _studentList
      .where((name) => _records.any((r) =>
          _normalizeName(r.name) == _normalizeName(name) && !r.isAbsent))
      .toList();
  List<String> get absentStudents =>
      _studentList.where((name) => !presentStudents.contains(name)).toList();
  List<String> get unknownStudents => _records
      .where((r) => _normalizeName(r.name) == 'unknown')
      .map((r) => r.name)
      .toSet()
      .toList();

  /*------------------
   Persistence Methods
  -------------------*/
  
  /// Initializes the log by loading saved records
  Future<void> initialize() async => await _loadRecords();

  /// Loads records from shared preferences
  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _records = jsonList
          .map((item) => AttendanceRecord.fromMap(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  /// Saves records to shared preferences
  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _records.map((record) => record.toMap()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
    notifyListeners();
  }

  /*------------------
   Utility Methods
  -------------------*/
  
  /// Normalizes names for consistent comparison
  String _normalizeName(String name) => name.trim().toLowerCase();

  /*------------------
   Data Management Methods
  -------------------*/
  
  /// Sets the student list and normalizes all names
  void setStudentList(List<String> students) {
    _studentList = students.map(_normalizeName).toList();
    debugPrint("Set student list: $_studentList");
    notifyListeners();
  }

  /// Adds recognition results to the log
  Future<void> addRecognitionResult(List<String> names) async {
    final now = DateTime.now();
    
    for (final name in names) {
      final normalizedName = _normalizeName(name);
      
      if (_studentList.contains(normalizedName) || normalizedName == 'unknown') {
        _records.add(AttendanceRecord(
          name: name,
          timestamp: now,
          isAbsent: normalizedName == 'unknown',
        ));
        debugPrint("Added record: $name");
      } else {
        debugPrint("Skipped name (not in student list): $name");
      }
    }
    
    await _saveRecords();
  }

  /// Adds a manual attendance entry
  Future<void> addManualEntry(String name) async {
    final normalizedName = _normalizeName(name);
    
    if (_studentList.contains(normalizedName)) {
      _records.add(AttendanceRecord(
        name: name,
        timestamp: DateTime.now(),
        isManualEntry: true,
        isAbsent: false,
      ));
      debugPrint("Added manual entry: $name");
      await _saveRecords();
    } else {
      debugPrint("Manual entry rejected (not in student list): $name");
    }
  }

  /// Clears all records and student list
  Future<void> clearAllRecords() async {
    _records.clear();
    _studentList.clear();
    await _saveRecords();
  }

  /// Filters records based on various criteria
  List<AttendanceRecord> filterRecords({
    String? nameFilter,
    DateTime? dateFilter,
    bool? showManualEntries,
    bool? showUnknownOnly,
  }) {
    return _records.where((record) {
      bool matches = true;
      
      // Name filter
      if (nameFilter != null && nameFilter.isNotEmpty) {
        matches = matches && 
            _normalizeName(record.name).contains(_normalizeName(nameFilter));
      }
      
      // Date filter
      if (dateFilter != null) {
        matches = matches && 
            record.timestamp.year == dateFilter.year &&
            record.timestamp.month == dateFilter.month &&
            record.timestamp.day == dateFilter.day;
      }
      
      // Manual entries filter
      if (showManualEntries != null) {
        matches = matches && (record.isManualEntry == showManualEntries);
      }
      
      // Unknown only filter
      if (showUnknownOnly != null && showUnknownOnly) {
        matches = matches && _normalizeName(record.name) == 'unknown';
      }
      
      return matches;
    }).toList();
  }
}