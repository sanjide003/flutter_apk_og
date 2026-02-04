import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/academic_year_tab.dart';
import 'tabs/hr_management_tab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  // നാവിഗേഷൻ ഹിസ്റ്ററി സൂക്ഷിക്കാൻ
  final List<int> _navigationHistory = [0]; 

  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const AcademicYearTab(),
    const HrManagementTab(),
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
    "Dashboard", "Academic Year", "HR Management", "Students", 
    "Fee Structure", "Fee Assignment", "Fee Collection", 
    "Notices", "Reports", "Public Content", "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    // PopScope: ബാക്ക് ബട്ടൺ അമർത്തുമ്പോൾ എന്ത് ചെയ്യണം എന്ന് തീരുമാനിക്കുന്നു
    return PopScope(
      canPop: false, // ഓട്ടോമാറ്റിക് ആയി ക്ലോസ് ആകരുത്
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackPress();
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
                accountEmail: Text(currentUser?.email ?? "No Email"),
                currentAccountPicture: const CircleAvatar(child: Icon(Icons.admin_panel_settings)),
              ),
              _buildNavItem(0, Icons.dashboard, "Dashboard"),
              _buildNavItem(1, Icons.calendar_today, "Academic Year"),
              _buildNavItem(2, Icons.people, "HR Management"),
              _buildNavItem(3, Icons.school, "Students"),
              const Divider(),
              _buildNavItem(10, Icons.settings, "Settings"),
            ],
          ),
        ),
        body: _tabs[_selectedIndex],
      ),
    );
  }

  // ബാക്ക് ബട്ടൺ ലോജിക്
  void _handleBackPress() {
    if (_navigationHistory.length > 1) {
      // ഹിസ്റ്ററിയിൽ പഴയ ടാബ് ഉണ്ടെങ്കിൽ അങ്ങോട്ട് പോകുക
      setState(() {
        _navigationHistory.removeLast(); // ഇപ്പോഴത്തത് കളയുന്നു
        _selectedIndex = _navigationHistory.last; // തൊട്ടു മുമ്പത്തെ എടുക്കുന്നു
      });
    } else {
      // ഹിസ്റ്ററി തീർന്നാൽ (Dashboard-ൽ എത്തിയാൽ), പുറത്ത് പോകണോ എന്ന് ചോദിക്കാം 
      // അല്ലെങ്കിൽ ലോഗിനിലേക്ക് പോകാം. ഇവിടെ ആപ്പ് ക്ലോസ് ചെയ്യാൻ അനുവദിക്കുന്നു.
      Navigator.of(context).pop(); 
    }
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700]),
      title: Text(title, style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.05),
      onTap: () {
        // പുതിയ ടാബ് സെലക്ട് ചെയ്യുമ്പോൾ ഹിസ്റ്ററിയിലേക്ക് ചേർക്കുന്നു
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
            _navigationHistory.add(index);
          });
        }
        Navigator.pop(context);
      },
    );
  }
}