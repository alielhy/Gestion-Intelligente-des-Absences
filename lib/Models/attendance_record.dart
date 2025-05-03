class AttendanceRecord {
  final String id;
  final String classId;
  final DateTime date;
  final List<String> presentStudentIds;
  final List<String> absentStudentIds;
  
  AttendanceRecord({
    required this.id,
    required this.classId,
    required this.date,
    required this.presentStudentIds,
    required this.absentStudentIds,
  });
  
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      classId: json['classId'],
      date: DateTime.parse(json['date']),
      presentStudentIds: List<String>.from(json['presentStudentIds']),
      absentStudentIds: List<String>.from(json['absentStudentIds']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'date': date.toIso8601String(),
      'presentStudentIds': presentStudentIds,
      'absentStudentIds': absentStudentIds,
    };
  }
}