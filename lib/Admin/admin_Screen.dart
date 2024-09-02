import 'package:box_booking_project/Admin/add_box_screen.dart';
import 'package:box_booking_project/Admin/admin_profile_screen.dart';
import 'package:box_booking_project/Admin/dashbord_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminAddBoxScreen(),
    const AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const [
          Icons.home,
          Icons.dashboard,
          Icons.person,
        ],
        activeIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        shadow: Shadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, -2),
          blurRadius: 8,
        ),
      ),
    );
  }
}
