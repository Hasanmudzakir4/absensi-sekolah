import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key});

  @override
  BarcodePageState createState() => BarcodePageState();
}

class BarcodePageState extends State<BarcodePage> {
  String? qrData;
  User? _user;
  String? _teacherName;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _fetchTeacherNameAndActiveSchedule();
    } else {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _fetchTeacherNameAndActiveSchedule() async {
    await initializeDateFormatting('id_ID', null);
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(_user!.uid)
              .get();
      if (!mounted) return;
      setState(() {
        _teacherName = (userDoc['name'] as String).trim();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
      });
      return;
    }

    await _fetchActiveSchedule();
    if (!mounted) return;
    setState(() {
      _isFetching = false;
    });
  }

  Future<void> _fetchActiveSchedule() async {
    if (_user == null) return;

    final now = DateTime.now();
    final today = DateFormat('EEEE', 'id_ID').format(now);

    try {
      // Ambil jadwal dari Firestore berdasarkan teacherId dan hari ini
      final snapshot =
          await FirebaseFirestore.instance
              .collection('schedules')
              .where('teacherId', isEqualTo: _user!.uid)
              .where('day', isEqualTo: today)
              .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final timeRange = data['time']?.split(" - ");
        if (timeRange == null || timeRange.length != 2) continue;

        final start = DateFormat("HH:mm").parse(timeRange[0]);
        final end = DateFormat("HH:mm").parse(timeRange[1]);

        final startTime = DateTime(
          now.year,
          now.month,
          now.day,
          start.hour,
          start.minute,
        );
        final endTime = DateTime(
          now.year,
          now.month,
          now.day,
          end.hour,
          end.minute,
        );

        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          // Jadwal aktif ditemukan
          final schedule = ScheduleModel(
            id: doc.id,
            subject: data['subject'] ?? '',
            day: data['day'] ?? '',
            time: data['time'] ?? '',
            teacherId: data['teacherId'] ?? '',
            teacherName: data['teacherName'] ?? '',
            className: data['className'] ?? '',
            semester: data['semester'] ?? '',
          );

          final hash = await _generateAndStoreQRData(schedule);
          if (!mounted) return;
          setState(() {
            qrData = hash;
          });
          return;
        }
      }

      // Tidak ada jadwal aktif
      if (!mounted) return;
      setState(() {
        qrData = null;
      });
    } catch (e) {
      debugPrint("Error fetching active schedule: $e");
      if (!mounted) return;
      setState(() {
        qrData = null;
      });
    }
  }

  /// Generate data, hash it, store it in Firestore, and return hash string.
  Future<String> _generateAndStoreQRData(ScheduleModel schedule) async {
    final data = {
      "teacher": _teacherName ?? '',
      "subject": schedule.subject,
      "day": schedule.day,
      "time": DateFormat("HH:mm").format(DateTime.now()),
      "date": DateFormat("dd-MM-yyyy").format(DateTime.now()),
      "status": "Hadir",
      "scheduleId": schedule.id,
      "createdAt": FieldValue.serverTimestamp(),
    };

    final raw = data.entries.map((e) => "${e.key}:${e.value}").join(";");
    final hash = sha256.convert(utf8.encode(raw)).toString();

    final qrRef = FirebaseFirestore.instance.collection("qr_codes").doc(hash);
    final existing = await qrRef.get();

    // Hindari overwrite jika hash sudah pernah dibuat sebelumnya
    if (!existing.exists) {
      await qrRef.set(data);
    }

    return hash;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Jadwal'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child:
            _isFetching
                ? const CircularProgressIndicator()
                : (_teacherName == null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 250,
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
                    )
                    : (qrData != null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Silahkan Absen",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            QrImageView(
                              data: qrData!,
                              size: 250,
                              backgroundColor: Colors.white,
                            ),
                          ],
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 250,
                              child: Lottie.asset('images/empty-data.json'),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Tidak ada absen saat ini.",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ))),
      ),
    );
  }
}
