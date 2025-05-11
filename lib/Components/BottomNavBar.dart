import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/CampMenuPage');
        break;
      case 2:
        Navigator.pushNamed(context, '/addPhoto');
        break;
      case 3:
        // Navigator.pushNamed(context, '/notifications');
        break;
      case 4:
        Navigator.pushNamed(context, '/userProfile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF2ECC71),
      unselectedItemColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 5, 58, 7),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.filter_hdr),
          label: "CampSites",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Notifications",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ],
    );
  }
}
