import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:absensi/src/models/attendance_model.dart';

class AttendanceController {
  // Mengambil data absensi berdasarkan UID user
  Future<List<AttendanceModel>> getAttendanceHistory() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('studentNumber', isEqualTo: user.uid)
              .get();

      List<AttendanceModel> attendanceList =
          snapshot.docs.map((doc) {
            return AttendanceModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      return attendanceList;
    } catch (e) {
      debugPrint("Error fetching attendance data: $e");
      return [];
    }
  }

  Future<List<AttendanceModel>> getAttendanceByScheduleId(
    String scheduleId,
  ) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('scheduleId', isEqualTo: scheduleId)
              .get();

      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching attendance by scheduleId: $e");
      return [];
    }
  }
}
