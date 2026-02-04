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
  
  // നാവിഗേഷൻ ഹിസ്റ്ററി (ബാക്ക് അടിക്കുമ്പോൾ പഴയ ടാബിലേക്ക് പോകാൻ)
  final List<int> _navHistory = [0]; 
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // എല്ലാ ടാബുകളും ഇവിടെ ലിങ്ക് ചെയ്തിരിക്കുന്നു
  final List<Widget> _tabs = [
    const DashboardTab(),          // 0
    const AcademicYearTab(),       // 1
    const HrManagementTab(),       // 2
    const StudentManagementTab(),  // 3
    const FeeStructureTab(),       // 4
    const Center(child: Text("Fee Assignment (Use Student Profile)")), // 5 (Placeholder)
    const Center(child: Text("Fee Collection (Use Staff App)")),       // 6 (Placeholder)
    const NoticesTab(),            // 7
    const Center(child: Text("Reports (Coming Soon)")),                // 8
    const Center(child: Text("Public Content (Coming Soon)")),         // 9
    const Center(child: Text("Settings")),                             // 10
  ];

  final List<String> _titles = [
    "Dashboard", "Academic Year", "HR Management", "Students", 
    "Fee Structure", "Fee Assignment", "Fee Collection", 
    "Notices", "Reports", "Public Content", "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ബാക്ക് ബട്ടൺ നമ്മൾ കൈകാര്യം ചെയ്യുന്നു
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_navHistory.length > 1) {
          setState(() {
            _navHistory.removeLast();
            _selectedIndex = _navHistory.last;
          });
        } else {
          // ഡാഷ്ബോർഡിൽ എത്തിയാൽ ആപ്പ് ക്ലോസ് ചെയ്യാം
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
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
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                ),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.blue : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal
        ),
      ),
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