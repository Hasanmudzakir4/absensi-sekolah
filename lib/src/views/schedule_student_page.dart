import 'package:absensi/src/controllers/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/schedule_model.dart';

class ScheduleStudentPage extends StatefulWidget {
  const ScheduleStudentPage({super.key});

  @override
  State<ScheduleStudentPage> createState() => _ScheduleStudentPageState();
}

class _ScheduleStudentPageState extends State<ScheduleStudentPage> {
  final ScheduleController _scheduleController = ScheduleController();
  late Future<List<ScheduleModel>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _loadStudentSchedules();
  }

  Future<List<ScheduleModel>> _loadStudentSchedules() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (!userDoc.exists) return [];

    final className = userDoc['studentClass'] as String? ?? '';
    final semester = userDoc['studentSemester'] as String? ?? '';

    List<ScheduleModel> schedules = await _scheduleController
        .fetchSchedulesForStudent(className, semester);

    // Sorting by day and time
    schedules.sort((a, b) {
      const dayOrder = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final indexA = dayOrder.indexOf(a.day);
      final indexB = dayOrder.indexOf(b.day);
      if (indexA != indexB) return indexA.compareTo(indexB);

      final timeA = _parseTime(a.time);
      final timeB = _parseTime(b.time);
      return timeA.compareTo(timeB);
    });

    return schedules;
  }

  DateTime _parseTime(String timeStr) {
    try {
      final start = timeStr.split('-').first.trim();
      final parts = start.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(0, 1, 1, hour, minute);
    } catch (_) {
      return DateTime(0, 1, 1, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<ScheduleModel>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    child: Lottie.asset('images/account-setup.json'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Lengkapi data pribadi Anda.",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          final schedules = snapshot.data;
          if (schedules == null || schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    child: Lottie.asset('images/empty-data.json'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Tidak ada jadwal untuk Anda.",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, i) {
              final s = schedules[i];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.subject,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Guru: ${s.teacherName}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hari: ${s.day}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            "Jam: ${s.time}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
