import 'package:flutter/material.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _StaffTile(title: 'Dashboard', subtitle: 'Today’s collections'),
          _StaffTile(title: 'Fee Collection', subtitle: 'Collect and save fees'),
          _StaffTile(title: 'Student List', subtitle: 'View-only student info'),
          _StaffTile(title: 'Notices', subtitle: 'Office updates'),
          _StaffTile(title: 'Profile', subtitle: 'Your details'),
        ],
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
