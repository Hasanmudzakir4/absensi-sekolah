import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String day;
  final String subject;
  final String time;
  final String teacherName;
  final String teacherId;
  final String className;
  final String semester;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScheduleModel({
    required this.id,
    required this.day,
    required this.subject,
    required this.time,
    required this.teacherName,
    required this.teacherId,
    required this.className,
    required this.semester,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'subject': subject,
      'time': time,
      'teacherName': teacherName,
      'teacherId': teacherId,
      'className': className,
      'semester': semester,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScheduleModel(
      id: documentId,
      day: map['day'] ?? '',
      subject: map['subject'] ?? '',
      time: map['time'] ?? '',
      teacherName: map['teacherName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      className: map['className'] ?? '',
      semester: map['semester'] ?? '',
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }
}
