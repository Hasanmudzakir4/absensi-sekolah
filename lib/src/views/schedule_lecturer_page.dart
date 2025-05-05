import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../controllers/schedule_controller.dart';
import '../models/schedule_model.dart';

class ScheduleLecturerPage extends StatefulWidget {
  const ScheduleLecturerPage({super.key});

  @override
  ScheduleLecturerPageState createState() => ScheduleLecturerPageState();
}

class ScheduleLecturerPageState extends State<ScheduleLecturerPage> {
  final ScheduleController _controller = ScheduleController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  bool _isLoading = false;
  bool _showForm = false;

  User? _user;
  String? _teacherName;
  ScheduleModel? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _fetchTeacherName();
    }
  }

  Future<void> _fetchTeacherName() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(_user!.uid)
              .get();

      setState(() {
        _teacherName = userDoc['name'];
      });
    } catch (e) {
      if (kDebugMode) {
        print("Lengkapi profil Anda!");
      }
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final String formattedTime =
          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Future<void> _addOrUpdateSchedule() async {
    if (_dayController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        _classController.text.isEmpty ||
        _semesterController.text.isEmpty ||
        _teacherName == null ||
        _user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua field harus diisi")),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String timeRange =
          "${_startTimeController.text} - ${_endTimeController.text}";

      // Buat objek schedule dengan menambahkan guruId dari _user.uid
      ScheduleModel schedule = ScheduleModel(
        id: _selectedSchedule?.id ?? '',
        day: _dayController.text,
        subject: _subjectController.text,
        time: timeRange,
        teacherName: _teacherName!,
        teacherId: _user!.uid,
        className: _classController.text,
        semester: _semesterController.text,
      );

      if (_selectedSchedule == null) {
        // Tambah jadwal baru
        await _controller.addSchedule(schedule);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jadwal berhasil ditambahkan")),
          );
        }
      } else {
        // Update jadwal yang sudah ada
        await _controller.updateSchedule(schedule.id, schedule);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jadwal berhasil diperbarui")),
          );
        }
      }

      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(ScheduleModel schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Konfirmasi Hapus"),
            content: const Text(
              "Apakah Anda yakin ingin menghapus jadwal ini?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus"),
              ),
            ],
          ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      await _controller.deleteSchedule(schedule.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Jadwal dihapus")));
        setState(() {});
      }
    }
  }

  void _resetForm() {
    _dayController.clear();
    _subjectController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _classController.clear();
    _semesterController.clear();
    _selectedSchedule = null;
    _showForm = false;
    setState(() {});
  }

  Widget _buildScheduleList() {
    if (_teacherName == null) {
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

    return FutureBuilder<List<ScheduleModel>>(
      future: _controller.fetchSchedulesByTeacher(_teacherName!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Terjadi kesalahan"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                  "Tidak ada jadwal.",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Urutkan jadwal berdasarkan hari dan jam
        final List<String> daysOrder = [
          "Senin",
          "Selasa",
          "Rabu",
          "Kamis",
          "Jumat",
          "Sabtu",
          "Minggu",
        ];

        schedules.sort((a, b) {
          // Urutkan berdasarkan hari terlebih dahulu
          int indexA = daysOrder.indexOf(a.day);
          int indexB = daysOrder.indexOf(b.day);
          if (indexA != indexB) {
            return indexA.compareTo(indexB);
          }

          // Jika hari sama, urutkan berdasarkan waktu mulai
          final startTimeA = a.time.split(" - ")[0];
          final startTimeB = b.time.split(" - ")[0];

          return startTimeA.compareTo(startTimeB);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          schedule.subject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  _dayController.text = schedule.day;
                                  _subjectController.text = schedule.subject;
                                  final times = schedule.time.split(" - ");
                                  if (times.length == 2) {
                                    _startTimeController.text = times[0];
                                    _endTimeController.text = times[1];
                                  }
                                  _classController.text = schedule.className;
                                  _semesterController.text = schedule.semester;
                                  _showForm = true;
                                  _selectedSchedule = schedule;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(schedule),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text("Hari: ${schedule.day}"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        Text("Jam: ${schedule.time}"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.class_, size: 18),
                        const SizedBox(width: 8),
                        Text("Kelas: ${schedule.className}"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.school, size: 18),
                        const SizedBox(width: 8),
                        Text("Semester: ${schedule.semester}"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _dayController,
          decoration: const InputDecoration(
            labelText: "Hari",
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _subjectController,
          decoration: const InputDecoration(
            labelText: "Mata Pelajaran",
            prefixIcon: Icon(Icons.book),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // Input Jam Mulai dan Selesai
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Jam Mulai",
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _pickTime(_startTimeController),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _endTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Jam Selesai",
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _pickTime(_endTimeController),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _classController,
          decoration: const InputDecoration(
            labelText: "Kelas",
            prefixIcon: Icon(Icons.class_),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _semesterController,
          decoration: const InputDecoration(
            labelText: "Semester",
            prefixIcon: Icon(Icons.school),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
              onPressed: _addOrUpdateSchedule,
              child: Text(
                _selectedSchedule == null
                    ? "Tambahkan Jadwal"
                    : "Perbarui Jadwal",
              ),
            ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Mengajar"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Daftar Jadwal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildScheduleList(),
            const SizedBox(height: 10),
            if (_teacherName != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showForm = !_showForm;
                    if (!_showForm) {
                      _resetForm();
                    }
                  });
                },
                child: Text(_showForm ? "Tutup Form" : "Tambah Jadwal"),
              ),
            const SizedBox(height: 10),
            if (_showForm && _teacherName != null) _buildForm(),
          ],
        ),
      ),
    );
  }
}
