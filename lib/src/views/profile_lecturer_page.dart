import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileLecturerPage extends StatefulWidget {
  const ProfileLecturerPage({super.key});

  @override
  ProfileLecturerPageState createState() => ProfileLecturerPageState();
}

class ProfileLecturerPageState extends State<ProfileLecturerPage> {
  final ProfileController _profileController = ProfileController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Pisahkan Tempat Lahir dan Tanggal Lahir
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    UserModel? user = await _profileController.getProfile();
    if (user != null) {
      setState(() {
        _nameController.text = user.name ?? '';
        _idNumberController.text = user.idNumber ?? '';
        _subjectController.text = user.subject ?? '';
        _phoneController.text = user.phone ?? '';
        // Jika field dob sudah berisi data dengan format "Tempat, Tanggal"
        if (user.dateOfBirth != null && user.dateOfBirth!.contains(',')) {
          var parts = user.dateOfBirth!.split(',');
          _birthPlaceController.text = parts[0].trim();
          _birthDateController.text = parts.length > 1 ? parts[1].trim() : '';
        } else {
          _birthPlaceController.text = user.dateOfBirth ?? '';
          _birthDateController.text = '';
        }
      });
    }
  }

  void _saveProfile() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final oldProfile = await _profileController.getProfile();

      String dobCombined = _birthPlaceController.text;
      if (_birthDateController.text.isNotEmpty) {
        dobCombined += ', ${_birthDateController.text}';
      }

      UserModel userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: _nameController.text,
        idNumber: _idNumberController.text,
        subject: _subjectController.text,
        phone: _phoneController.text,
        dateOfBirth: dobCombined,
        role: oldProfile?.role,
      );

      try {
        await _profileController.saveProfile(userModel);
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/tabbar');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime initialDate = DateTime.now().subtract(
      const Duration(days: 365 * 20),
    );
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nameController, "Nama Lengkap", Icons.person),
            _buildTextField(_idNumberController, "NIDN", Icons.badge),
            _buildTextField(_subjectController, "Mata Kuliah", Icons.class_),
            _buildTextField(
              _phoneController,
              "Telepon",
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              _birthPlaceController,
              "Tempat Lahir",
              Icons.location_city,
            ),
            _buildTextField(
              _birthDateController,
              "Tanggal Lahir",
              Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectBirthDate(context),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Simpan Profil"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
