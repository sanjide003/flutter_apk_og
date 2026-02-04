import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/dashboard_tab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // ടാബുകൾ (ഇപ്പോൾ ഡാഷ്ബോർഡ് മാത്രം, ബാക്കി Empty)
  final List<Widget> _tabs = [
    const DashboardTab(),
    const Center(child: Text("Academic Year Mgmt - No Data")),
    const Center(child: Text("HR Mgmt - No Data")),
    // ... ബാക്കി ടാബുകൾ പിന്നീട് ഡാറ്റ വരുമ്പോൾ കാണിക്കാം
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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
          children: [
             UserAccountsDrawerHeader(
              accountName: const Text("Administrator"),
              accountEmail: Text(currentUser?.email ?? "No Email"),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(leading: const Icon(Icons.dashboard), title: const Text("Dashboard"), onTap: () => _select(0)),
            // ബാക്കി മെനു ഐറ്റംസ് ഇവിടെ വരും
          ],
        ),
      ),
      body: _tabs.isNotEmpty ? _tabs[_selectedIndex] : const Center(child: Text("No Tabs")),
    );
  }

  void _select(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }
}
