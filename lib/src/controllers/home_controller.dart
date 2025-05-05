import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mengambil nama hari ini dalam bahasa Indonesia
  String _getToday() {
    return DateFormat(
      'EEEE',
      'id_ID',
    ).format(DateTime.now()).toLowerCase().trim();
  }

  /// Mengambil jadwal hari ini untuk student berdasarkan kelas dan semester
  Future<List<ScheduleModel>> fetchSchedulesForTodayStudent(
    String studentClass,
    String semester,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('schedules')
              .where('className', isEqualTo: studentClass.trim())
              .where('semester', isEqualTo: semester.trim())
              .get();

      final allSchedules =
          querySnapshot.docs.map((doc) {
            return ScheduleModel.fromMap(doc.data(), doc.id);
          }).toList();

      final today = _getToday();

      // Hanya mengambil jadwal yang sesuai dengan hari ini
      final todaySchedules =
          allSchedules.where((schedule) {
            return schedule.day.toLowerCase().trim() == today;
          }).toList();

      // Urutkan jadwal berdasarkan waktu mulai
      todaySchedules.sort(_compareSchedulesByStartTime);
      return todaySchedules;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching schedules for today: $e");
      }
      return [];
    }
  }

  /// Mengambil jadwal hari ini untuk lecturer
  Future<List<ScheduleModel>> fetchSchedulesForTodayLecturer(
    String teacherName,
  ) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('schedules')
              .where('teacherName', isEqualTo: teacherName.trim())
              .get();

      List<ScheduleModel> lecturerSchedules =
          querySnapshot.docs.map((doc) {
            return ScheduleModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      // Ambil hari ini dalam format Bahasa Indonesia
      String today = DateFormat('EEEE', 'id_ID').format(DateTime.now());

      // Filter hanya yang sesuai hari ini
      List<ScheduleModel> todayLecturerSchedules =
          lecturerSchedules.where((schedule) {
            return schedule.day.toLowerCase().trim() ==
                today.toLowerCase().trim();
          }).toList();

      // Urutkan berdasarkan waktu mulai
      todayLecturerSchedules.sort((a, b) {
        try {
          String startA = a.time.split('-')[0].trim();
          String startB = b.time.split('-')[0].trim();

          final timeA = DateFormat("HH:mm").parse(startA);
          final timeB = DateFormat("HH:mm").parse(startB);

          return timeA.compareTo(timeB);
        } catch (_) {
          return 0;
        }
      });

      return todayLecturerSchedules;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching lecturer schedules for today: $e");
      }
      return [];
    }
  }

  // Fungsi pembantu untuk mengurutkan berdasarkan waktu mulai
  int _compareSchedulesByStartTime(ScheduleModel a, ScheduleModel b) {
    try {
      final startA = a.time.split('-')[0].trim();
      final startB = b.time.split('-')[0].trim();
      final timeA = DateFormat("HH:mm").parseStrict(startA);
      final timeB = DateFormat("HH:mm").parseStrict(startB);
      return timeA.compareTo(timeB);
    } catch (e) {
      if (kDebugMode) {
        print("Error parsing time: $e");
      }
      return 0;
    }
  }
}
