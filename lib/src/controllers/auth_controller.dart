import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  // FUngsi ambil data profile
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      // Ambil data pengguna dari Firestore berdasarkan UID
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      return null;
    }
  }

  // Fungsi Login
  Future<User?> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.reload();
        user = _auth.currentUser;

        if (!user!.emailVerified) {
          if (context.mounted) {
            _showDialog(
              context,
              "Verifikasi Diperlukan",
              "Akun Anda belum diverifikasi. Silakan periksa email dan klik link verifikasi terlebih dahulu.",
            );
          }
          return null;
        }

        // Cek apakah data user sudah disimpan di Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          if (context.mounted) {
            _showDialog(
              context,
              "Akun Tidak Ditemukan",
              "Email Anda sudah terverifikasi, tetapi data belum lengkap. Silakan verifikasi ulang melalui halaman sebelumnya.",
            );
          }
          return null;
        }

        // Email sudah diverifikasi dan data ditemukan
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/tabbar');
        }

        return user;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showDialog(context, "Login Gagal", _getAuthErrorMessage(e.code));
      }
      return null;
    }
  }

  // Fungsi Registrasi
  Future<User?> register(
    String email,
    String password,
    String role,
    BuildContext context,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      if (context.mounted) {
        _showDialog(context, "Input Error", "Silahkan isi email dan password.");
      }
      return null;
    }

    setLoading(true);
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Kirim email verifikasi setelah registrasi
      await userCredential.user!.sendEmailVerification();

      setLoading(false);

      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/otp',
          arguments: {'role': role},
        );
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      if (context.mounted) {
        _showDialog(
          context,
          "Registration Error",
          _getAuthErrorMessage(e.code),
        );
      }
      return null;
    }
  }

  // Fungsi Logout
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    notifyListeners();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Fungsi Menampilkan Dialog
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Fungsi Mapping Error FirebaseAuthException
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Email sudah terdaftar.";
      case 'invalid-email':
        return "Format email tidak valid.";
      case 'user-not-found':
        return "Akun tidak ditemukan.";
      case 'invalid-credential':
        return "Email atau password salah.";
      case 'user-disabled':
        return "Akun telah dinonaktifkan.";
      default:
        return "Terjadi kesalahan: $code";
    }
  }
}
