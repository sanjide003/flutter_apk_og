import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/academic_year_tab.dart'; // Import
import 'tabs/hr_management_tab.dart'; // Import

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // പുതിയ ടാബുകൾ ഇവിടെ ചേർത്തു
  final List<Widget> _tabs = [
    const DashboardTab(),
    const AcademicYearTab(), // Real Tab
    const HrManagementTab(), // Real Tab
    const Center(child: Text("Students (Coming Soon)")),
    const Center(child: Text("Fee Structure (Coming Soon)")),
    const Center(child: Text("Fee Assignment (Coming Soon)")),
    const Center(child: Text("Fee Collection (Coming Soon)")),
    const Center(child: Text("Notices (Coming Soon)")),
    const Center(child: Text("Reports (Coming Soon)")),
    const Center(child: Text("Public Content (Coming Soon)")),
    const Center(child: Text("Settings (Coming Soon)")),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Academic Year",
    "HR Management",
    "Students",
    "Fee Structure",
    "Fee Assignment",
    "Fee Collection",
    "Notices",
    "Reports",
    "Public Content",
    "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              }
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Remove top padding
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Administrator"),
              accountEmail: Text(currentUser?.email ?? "No Email"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            _buildNavItem(0, Icons.dashboard, "Dashboard"),
            _buildNavItem(1, Icons.calendar_today, "Academic Year"),
            _buildNavItem(2, Icons.people, "HR Management"),
            _buildNavItem(3, Icons.school, "Students"),
            _buildNavItem(4, Icons.monetization_on, "Fee Structure"),
            _buildNavItem(5, Icons.assignment_ind, "Fee Assignment"),
            _buildNavItem(6, Icons.payment, "Fee Collection"),
            const Divider(),
            _buildNavItem(7, Icons.campaign, "Notices"),
            _buildNavItem(8, Icons.bar_chart, "Reports"),
            _buildNavItem(9, Icons.public, "Public Content"),
            _buildNavItem(10, Icons.settings, "Settings"),
          ],
        ),
      ),
      body: _tabs[_selectedIndex],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.05),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
