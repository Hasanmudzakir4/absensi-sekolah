import 'package:flutter/material.dart';
import 'package:absensi/src/views/welcome_page.dart';
import 'package:absensi/src/views/splash_page.dart';
import 'package:absensi/src/views/login_page.dart';
import 'package:absensi/src/views/register_page.dart';
import 'package:absensi/src/views/otp_page.dart';
import 'package:absensi/src/views/tabbar.dart';
import 'package:absensi/src/views/account_student_page.dart';
import 'package:absensi/src/views/account_lecturer_page.dart';
import 'package:absensi/src/views/history_lecturer_page.dart';
import 'package:absensi/src/views/history_student_page.dart';
import 'package:absensi/src/views/home_student_page.dart';
import 'package:absensi/src/views/home_lecturer_page.dart';
import 'package:absensi/src/views/profile_lecturer_page.dart';
import 'package:absensi/src/views/profile_student_page.dart';
import 'package:absensi/src/views/schedule_lecturer_page.dart';
import 'package:absensi/src/views/schedule_student_page.dart';
import 'package:absensi/src/views/barcode_page.dart';
import 'package:absensi/src/views/scanner_page.dart';
import 'package:absensi/src/views/not_found_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String tabbar = '/tabbar';
  static const String homeStudent = '/homeStudent';
  static const String homeLecturer = '/homeLecturer';
  static const String historyLecturer = '/historyLecturer';
  static const String historyStudent = '/historyStudent';
  static const String accountLecturer = '/accountLecturer';
  static const String scheduleLecturer = '/scheduleLecturer';
  static const String scheduleStudent = '/scheduleStudent';
  static const String accountStudent = '/accountStudent';
  static const String profileLecturer = '/profileLecturer';
  static const String profileStudent = '/profileStudent';
  static const String detailAbsen = '/detailAbsen';
  static const String scan = '/scan';
  static const String barcode = '/barcode';

  static Widget getPageByRouteName(String? routeName) {
    switch (routeName) {
      case splash:
        return SplashPage();
      case welcome:
        return WelcomePage();
      case login:
        return LoginPage();
      case register:
        return RegisterPage();
      case otp:
        return OTPPage();
      case tabbar:
        return TabBarScreen();
      case homeStudent:
        return HomeStudentPage();
      case homeLecturer:
        return HomeLecturerPage();
      case historyLecturer:
        return HistoryLecturerPage();
      case historyStudent:
        return HistoryStudentPage();
      case accountStudent:
        return AccountStudentPage();
      case accountLecturer:
        return AccountLecturerPage();
      case scheduleLecturer:
        return ScheduleLecturerPage();
      case profileStudent:
        return ProfileStudentPage();
      case scheduleStudent:
        return ScheduleStudentPage();
      case profileLecturer:
        return ProfileLecturerPage();
      case detailAbsen:
        return HistoryStudentPage();
      case barcode:
        return BarcodePage();
      case scan:
        return ScanPage();
      default:
        return NotFoundPage();
    }
  }

  // ✅ Tambahkan ini agar tidak error di main.dart
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => getPageByRouteName(settings.name),
      settings: settings,
    );
  }
}
