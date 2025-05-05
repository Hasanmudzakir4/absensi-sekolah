import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class AccountLecturerPage extends StatefulWidget {
  const AccountLecturerPage({super.key});

  @override
  State<AccountLecturerPage> createState() => _AccountLecturerPageState();
}

class _AccountLecturerPageState extends State<AccountLecturerPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final data = await authController.getUserData();

    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin ingin logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
              if (!mounted) return;
              if (confirmed == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  Provider.of<AuthController>(
                    context,
                    listen: false,
                  ).logout(context);
                });
              }
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : userData == null
              ? const Center(child: Text("Data pengguna tidak ditemukan."))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: const AssetImage(
                            'images/profil.png',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          userData?['name'] ?? 'Nama Tidak Diketahui',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: const Icon(Icons.perm_identity),
                        title: const Text("NIDN"),
                        subtitle: Text(userData?['idNumber'] ?? '-'),
                      ),

                      ListTile(
                        leading: const Icon(Icons.cake),
                        title: const Text("Tempat, Tanggal Lahir"),
                        subtitle: Text(userData?['dateOfBirth'] ?? '-'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.class_),
                        title: const Text("Mata Kuliah"),
                        subtitle: Text(userData?['subject'] ?? '-'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text("Email"),
                        subtitle: Text(userData?['email'] ?? '-'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text("Telepon"),
                        subtitle: Text(userData?['phone'] ?? '-'),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/profileLecturer');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text("Update Profile"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
