class Student {
  final String id;
  final String name;
  final String faceId; // Used for ML face detection matching
  
  Student({
    required this.id,
    required this.name,
    required this.faceId,
  });
  
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      faceId: json['faceId'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'faceId': faceId,
    };
  }
}