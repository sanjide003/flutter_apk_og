import 'package:flutter/material.dart';
import 'tabs/dashboard_tab.dart'; // ടാബ് ഇമ്പോർട്ട് ചെയ്യുന്നു

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  // 11 ടാബുകൾക്കുള്ള ലിസ്റ്റ് (ഇപ്പോൾ ഡാഷ്ബോർഡ് മാത്രം, ബാക്കി Placeholder)
  final List<Widget> _tabs = [
    const DashboardTab(),
    const Center(child: Text("Academic Year Management (Coming Soon)")),
    const Center(child: Text("HR Management (Coming Soon)")),
    const Center(child: Text("Student Management (Coming Soon)")),
    const Center(child: Text("Fee Structure (Coming Soon)")),
    const Center(child: Text("Fee Assignment (Coming Soon)")),
    const Center(child: Text("Fee Collection (Coming Soon)")),
    const Center(child: Text("Notices (Coming Soon)")),
    const Center(child: Text("Reports (Coming Soon)")),
    const Center(child: Text("Public Content (Coming Soon)")),
    const Center(child: Text("Settings (Coming Soon)")),
  ];

  // ടാബ് പേരുകൾ
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
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              // തിരിച്ച് ലോഗിനിലേക്ക് (Stack ക്ലിയർ ചെയ്യുന്നു)
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      // സൈഡ് മെനു (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Admin User"),
              accountEmail: const Text("Director / Principal"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            // Menu Items
            _buildNavItem(0, Icons.dashboard, "Dashboard"),
            _buildNavItem(1, Icons.calendar_today, "Academic Year"),
            _buildNavItem(2, Icons.people, "HR Management"),
            _buildNavItem(3, Icons.school, "Students"),
            _buildNavItem(4, Icons.monetization_on, "Fee Structure"),
            _buildNavItem(5, Icons.assignment_ind, "Fee Assignment"),
            _buildNavItem(6, Icons.payment, "Fee Collection"),
            _buildNavItem(7, Icons.campaign, "Notices"),
            _buildNavItem(8, Icons.bar_chart, "Reports"),
            _buildNavItem(9, Icons.public, "Public Content"),
            const Divider(),
            _buildNavItem(10, Icons.settings, "Settings"),
          ],
        ),
      ),
      body: _tabs[_selectedIndex], // സെലക്ട് ചെയ്ത ടാബ് കാണിക്കുന്നു
    );
  }

  // മെനു ഐറ്റം ഡിസൈൻ
  Widget _buildNavItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700]
      ),
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
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // മെനു അടയ്ക്കുന്നു
      },
    );
  }
}
