import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/staff_dashboard_tab.dart';
import 'tabs/fee_collection_tab.dart';
// ബാക്കിയുള്ള ടാബുകൾ പിന്നീട് ചേർക്കാം

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser; // ലോഗിൻ ചെയ്ത സ്റ്റാഫ്

  // TABS
  final List<Widget> _tabs = [
    const StaffDashboardTab(),      // 0: Dashboard
    const FeeCollectionTab(),       // 1: Fee Collection
    const Center(child: Text("Student Directory (Coming Soon)")), // 2
    const Center(child: Text("Transactions (Coming Soon)")),      // 3
    const Center(child: Text("Profile (Coming Soon)")),           // 4
    const Center(child: Text("Reports (Coming Soon)")),           // 5
  ];

  final List<String> _titles = [
    "Staff Dashboard", "Collect Fee", "Students", "Transactions", "Profile", "Reports"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Staff Member"), // ലോഗിൻ ചെയ്യുമ്പോൾ പേര് പാസ്സ് ചെയ്യാം
              accountEmail: Text(currentUser?.email ?? "Staff Access"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            _buildNavItem(0, Icons.dashboard, "Dashboard"),
            _buildNavItem(1, Icons.payment, "Fee Collection"),
            _buildNavItem(2, Icons.people, "Student Directory"),
            _buildNavItem(3, Icons.history, "Transactions"),
            const Divider(),
            _buildNavItem(4, Icons.person, "Profile"),
            _buildNavItem(5, Icons.bar_chart, "Reports"),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              },
            )
          ],
        ),
      ),
      body: _tabs[_selectedIndex],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? Theme.of(context).primaryColor : Colors.grey),
      title: Text(title, style: TextStyle(color: selected ? Theme.of(context).primaryColor : Colors.black, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      selected: selected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}