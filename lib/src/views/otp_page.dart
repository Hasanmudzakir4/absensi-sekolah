import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    role = args?['role'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verifikasi Email"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Kami telah mengirimkan email verifikasi. Silakan cek email Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _checkEmailVerified,
              child: const Text("Cek Verifikasi"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _resendVerification,
              child: const Text("Kirim Ulang Email Verifikasi"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: const Text("Ganti Email / Kembali ke Registrasi"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkEmailVerified() async {
    await _auth.currentUser?.reload();

    if (!mounted) return;

    final user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      // Jika role null, tampilkan error
      if (role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data. Role tidak tersedia.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': role,
        'createdAt': DateTime.now(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/tabbar');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email belum diverifikasi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verifikasi telah dikirim ulang.'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
