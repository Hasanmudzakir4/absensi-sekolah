import 'package:absensi/src/models/user_model.dart';
import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/schedule_model.dart';

class HomeStudentPage extends StatefulWidget {
  const HomeStudentPage({super.key});

  @override
  HomeStudentPageState createState() => HomeStudentPageState();
}

class HomeStudentPageState extends State<HomeStudentPage> {
  final HomeController _homeController = HomeController();
  final ProfileController _profileController = ProfileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<UserModel?>(
        future: _profileController.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Gagal mengambil data profil."));
          }

          UserModel user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade900, Colors.blue.shade400],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('images/profil.png'),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo, ${user.name ?? 'User'}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Kelas ${user.studentClass ?? '?'} | Semester ${user.studentSemester ?? '?'}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // STATUS KEHADIRAN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status Kehadiran",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "✅ Sudah Absen Masuk: 07:15",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // JADWAL PELAJARAN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "📅 Jadwal Hari Ini",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<ScheduleModel>>(
                  future: _homeController.fetchSchedulesForTodayStudent(
                    user.studentClass ?? '',
                    user.studentSemester ?? '',
                  ),
                  builder: (context, scheduleSnapshot) {
                    if (scheduleSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (scheduleSnapshot.hasError) {
                      return Center(
                        child: Text("Error: ${scheduleSnapshot.error}"),
                      );
                    } else if (!scheduleSnapshot.hasData ||
                        scheduleSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Tidak ada jadwal untuk hari ini."),
                      );
                    }

                    List<ScheduleModel> schedules = scheduleSnapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return ScheduleCard(
                          schedule.time,
                          schedule.subject,
                          schedule.teacherName,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // PENGUMUMAN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "📢 Pengumuman",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      "🛑 Ujian Tengah Semester mulai 20 Maret 2025!",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget Kartu Jadwal
class ScheduleCard extends StatelessWidget {
  final String time, subject, teacher;
  const ScheduleCard(this.time, this.subject, this.teacher, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.access_time, color: Colors.blue.shade800),
        title: Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$time | $teacher"),
      ),
    );
  }
}
