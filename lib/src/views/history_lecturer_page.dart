import 'package:absensi/src/controllers/history_controller.dart';
import 'package:absensi/src/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HistoryLecturerPage extends StatefulWidget {
  const HistoryLecturerPage({super.key});

  @override
  State<HistoryLecturerPage> createState() => _HistoryLecturerPageState();
}

class _HistoryLecturerPageState extends State<HistoryLecturerPage> {
  late Future<List<AttendanceModel>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = HistoryController().fetchLecturerAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absen Mahasiswa'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<AttendanceModel>>(
        future: _attendanceFuture,
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
                    child: Lottie.asset('images/404-notfound.json'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Terjadi Kesalahan.",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          final data = snapshot.data;
          if (data == null || data.isEmpty) {
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
                    "Belum ada data absen.",
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
            padding: const EdgeInsets.all(16.0),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final attendance = data[index];
              final qrData = attendance.qrData;

              return AttendanceDetailCard(
                date: qrData['date'] ?? "-",
                day: qrData['day'] ?? "-",
                timeIn: qrData['time'] ?? "-",
                subject: qrData['subject'] ?? "-",
                status: qrData['status'] ?? "Tidak Diketahui",
                student: attendance.studentName,
                studentNumber: attendance.studentNumber,
                studentClass: attendance.studentClass,
                studentSemester: attendance.studentSemester,
                scheduleId: attendance.scheduleId,
              );
            },
          );
        },
      ),
    );
  }
}

class AttendanceDetailCard extends StatelessWidget {
  final String date;
  final String day;
  final String timeIn;
  final String subject;
  final String student;
  final String studentNumber;
  final String studentClass;
  final String studentSemester;
  final String status;
  final String scheduleId;

  const AttendanceDetailCard({
    super.key,
    required this.day,
    required this.date,
    required this.timeIn,
    required this.subject,
    required this.student,
    required this.studentNumber,
    required this.studentClass,
    required this.studentSemester,
    required this.status,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = (status == "Hadir") ? Colors.green : Colors.red;
    IconData statusIcon =
        (status == "Hadir") ? Icons.check_circle : Icons.cancel;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nama : $student",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      "NIM : $studentNumber",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      "Kelas : $studentClass | Semester: $studentSemester", // ➕ Tambahkan ini
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Icon(statusIcon, color: statusColor, size: 28),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$day, $date",
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                Text(
                  timeIn,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
