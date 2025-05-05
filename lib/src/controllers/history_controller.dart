import 'package:absensi/src/models/attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryController {
  Future<List<AttendanceModel>> fetchAttendanceData() async {
    // Ambil data pengguna yang sedang login.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Ambil dokumen pengguna untuk mendapatkan NIM.
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (!userDoc.exists) return [];

    String studentNumber = userDoc['idNumber'];

    // Query absensi berdasarkan studentNim dan urutkan berdasarkan tanggal (dalam qrData).
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('attendance')
            .where('studentNumber', isEqualTo: studentNumber)
            .orderBy('qrData.date', descending: true)
            .get();

    // Konversi data dokumen menjadi objek AttendanceModel, dengan memasukkan doc.id
    List<AttendanceModel> attendanceList =
        querySnapshot.docs.map((doc) {
          return AttendanceModel.fromMap(doc.data(), doc.id);
        }).toList();

    return attendanceList;
  }

  Future<List<AttendanceModel>> fetchLecturerAttendanceData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Ambil semua jadwal yang dibuat oleh dosen yang login
    final scheduleSnapshot =
        await FirebaseFirestore.instance
            .collection('schedules')
            .where('teacherId', isEqualTo: user.uid)
            .get();

    if (scheduleSnapshot.docs.isEmpty) return [];

    // Ambil daftar scheduleId
    List<String> scheduleIds =
        scheduleSnapshot.docs.map((doc) => doc.id).toList();

    // Ambil semua data absensi yang memiliki scheduleId sesuai dengan dosen
    final attendanceSnapshot =
        await FirebaseFirestore.instance
            .collection('attendance')
            .where('scheduleId', whereIn: scheduleIds)
            .orderBy('timestamp', descending: true)
            .get();

    return attendanceSnapshot.docs
        .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
