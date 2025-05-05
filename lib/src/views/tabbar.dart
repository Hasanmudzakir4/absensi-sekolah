import 'package:flutter/material.dart';
import 'package:absensi/src/routes/app_routes.dart';
import 'package:absensi/src/controllers/profile_controller.dart';

class TabBarScreen extends StatefulWidget {
  const TabBarScreen({super.key});

  @override
  State<TabBarScreen> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final ProfileController _profileController = ProfileController();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role = await _profileController.getUserRole();
    setState(() {
      userRole = role;
    });
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    Color color = _selectedIndex == index ? Colors.blueAccent : Colors.grey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ambil halaman sesuai peran user
    final String homeRoute =
        userRole == "dosen" ? AppRoutes.homeLecturer : AppRoutes.homeStudent;

    final String historyRoute =
        userRole == "dosen"
            ? AppRoutes.historyLecturer
            : AppRoutes.historyStudent;

    final String scanRoute =
        userRole == "dosen" ? AppRoutes.barcode : AppRoutes.scan;

    final String scheduleRoute =
        userRole == "dosen"
            ? AppRoutes.scheduleLecturer
            : AppRoutes.scheduleStudent;

    final String accountRoute =
        userRole == "dosen"
            ? AppRoutes.accountLecturer
            : AppRoutes.accountStudent;

    final IconData scanIcon =
        userRole == "dosen" ? Icons.document_scanner : Icons.qr_code_scanner;

    final List<String> pageRoutes = [
      homeRoute,
      historyRoute,
      scanRoute,
      scheduleRoute,
      accountRoute,
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pageRoutes.map(AppRoutes.getPageByRouteName).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SafeArea(
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  _pageController.jumpToPage(2);
                },
                backgroundColor: Colors.blueAccent,
                child: Icon(scanIcon, size: 35),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(icon: Icons.home, label: 'Home', index: 0),
                _buildTabItem(icon: Icons.history, label: 'Riwayat', index: 1),
                const SizedBox(width: 60),
                _buildTabItem(icon: Icons.schedule, label: 'Jadwal', index: 3),
                _buildTabItem(icon: Icons.person, label: 'Profile', index: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
