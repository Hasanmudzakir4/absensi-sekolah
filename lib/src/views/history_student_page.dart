import 'package:absensi/src/controllers/history_controller.dart';
import 'package:absensi/src/models/attendance_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HistoryStudentPage extends StatefulWidget {
  const HistoryStudentPage({super.key});

  @override
  State<HistoryStudentPage> createState() => _HistoryStudentPageState();
}

class _HistoryStudentPageState extends State<HistoryStudentPage> {
  final HistoryController _controller = HistoryController();
  late Future<List<AttendanceModel>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _controller.fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Kehadiran"),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<AttendanceModel>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    "Tidak ada data absensi.",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final attendanceList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];
              final qrData = attendance.qrData;

              return AttendanceDetailCard(
                date: qrData['date'] ?? "-",
                day: qrData['day'] ?? "-",
                timeIn: qrData['time'] ?? "-",
                subject: qrData['subject'] ?? "-",
                teacher: qrData['teacher'] ?? "-",
                status: qrData['status'] ?? "Tidak Diketahui",
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
  final String teacher;
  final String status;
  final String scheduleId;

  const AttendanceDetailCard({
    super.key,
    required this.day,
    required this.date,
    required this.timeIn,
    required this.subject,
    required this.teacher,
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
                      "Guru: $teacher",
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
                  "Hari/ Tanggal: $day, $date",
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                Text(
                  "Jam: $timeIn",
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
