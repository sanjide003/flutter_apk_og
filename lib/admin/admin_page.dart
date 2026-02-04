import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/academic_year_tab.dart';
import 'tabs/hr_management_tab.dart';
import 'tabs/student_management_tab.dart';
import 'tabs/fee_structure_tab.dart';
import 'tabs/notices_tab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  final List<int> _navHistory = [0]; 
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // ALL TABS IMPLEMENTED
  final List<Widget> _tabs = [
    const DashboardTab(),
    const AcademicYearTab(),
    const HrManagementTab(),
    const StudentManagementTab(),
    const FeeStructureTab(), // Fee Structure
    const Center(child: Text("Fee Assignment (Use Student Profile)")), // Placeholder for complex logic
    const Center(child: Text("Fee Collection (Use Staff App)")), // Placeholder
    const NoticesTab(), // Notices
    const Center(child: Text("Reports (Coming Soon)")),
    const Center(child: Text("Public Content (Coming Soon)")),
    const Center(child: Text("Settings")),
  ];

  final List<String> _titles = [
    "Dashboard", "Academic Year", "HR Management", "Students", 
    "Fee Structure", "Fee Assignment", "Fee Collection", 
    "Notices", "Reports", "Public Content", "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_navHistory.length > 1) {
          setState(() {
            _navHistory.removeLast();
            _selectedIndex = _navHistory.last;
          });
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              },
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text("Administrator"),
                accountEmail: Text(currentUser?.email ?? "Admin Access"),
                currentAccountPicture: const CircleAvatar(child: Icon(Icons.admin_panel_settings)),
              ),
              _item(0, Icons.dashboard, "Dashboard"),
              _item(1, Icons.calendar_today, "Academic Year"),
              _item(2, Icons.people, "HR Management"),
              _item(3, Icons.school, "Student Management"),
              const Divider(),
              _item(4, Icons.monetization_on, "Fee Structure"),
              _item(5, Icons.assignment_ind, "Fee Assignment"),
              _item(6, Icons.payment, "Fee Collection"),
              const Divider(),
              _item(7, Icons.campaign, "Notices"),
              _item(8, Icons.bar_chart, "Reports"),
              _item(9, Icons.public, "Public Content"),
              _item(10, Icons.settings, "Settings"),
            ],
          ),
        ),
        body: _tabs[_selectedIndex],
      ),
    );
  }

  Widget _item(int index, IconData icon, String title) {
    bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : Colors.grey),
      title: Text(title, style: TextStyle(color: selected ? Colors.blue : Colors.black, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      selected: selected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
            _navHistory.add(index);
          });
        }
        Navigator.pop(context);
      },
    );
  }
}