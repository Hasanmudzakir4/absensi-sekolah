import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              buildPage(
                image: Image.asset(
                  'images/logo-tutwurihandayani.png',
                  fit: BoxFit.cover,
                ),
                title: 'Selamat Datang di E-Absensi Sekolah!',
                description:
                    'Aplikasi ini membantu siswa dan guru untuk mencatat kehadiran secara digital dengan mudah dan efisien.',
              ),
              buildPage(
                image: Lottie.asset('images/scanner.json'),
                title:
                    'Gunakan fitur scan QR Code untuk mencatat kehadiran dengan cepat dan akurat.',
                description:
                    'Tidak perlu tanda tangan manual! Cukup scan QR Code dan kehadiranmu akan tercatat otomatis.',
              ),
              buildPage(
                image: Lottie.asset('images/history.json'),
                title: 'Pantau Riwayat Kehadiran!',
                description:
                    'Dengan aplikasi ini, kamu bisa melihat riwayat absensi kapan saja dan di mana saja secara real-time.',
                showButton: true,
              ),
            ],
          ),

          // Navigasi Halaman Onboarding
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: const Text('Lewati'),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    dotWidth: 16.0,
                    dotHeight: 16.0,
                    dotColor: Colors.grey,
                    activeDotColor: Colors.blue,
                  ),
                ),
                onLastPage
                    ? GestureDetector(
                      onTap: navigateToHome,
                      child: const Text('Mulai'),
                    )
                    : GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text('Lanjut'),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required Widget image,
    required String title,
    required String description,
    bool showButton = false,
  }) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 65),
            Align(
              alignment: const Alignment(0, -0.8),
              child: FractionallySizedBox(widthFactor: 0.7, child: image),
            ),
            const SizedBox(height: 25),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              description,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            if (showButton) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: navigateToHome,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  'MULAI MENGGUNAKAN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
