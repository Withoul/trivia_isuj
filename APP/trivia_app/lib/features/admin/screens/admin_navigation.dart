import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'banks_list_screen.dart';
import 'bank_form_screen.dart';
import 'admin_profile_tab.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BanksListScreen(),
    const BankFormScreen(), // Creation mode
    const AdminProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAdmin,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppColors.primaryContainer),
            SizedBox(width: 8),
            Text(
              'Panel Administrativo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryContainer,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            activeIcon: Icon(Icons.dashboard_customize, color: AppColors.primaryContainer),
            label: 'Cuestionarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box, color: AppColors.primaryContainer),
            label: 'Nuevo Cuestionario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_outlined),
            activeIcon: Icon(Icons.supervised_user_circle, color: AppColors.primaryContainer),
            label: 'Perfil Admin',
          ),
        ],
      ),
    );
  }
}
