import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _StudentTile(title: 'Fee Status', subtitle: 'Paid vs due fees'),
          _StudentTile(title: 'Profile', subtitle: 'Personal details'),
          _StudentTile(title: 'Notices', subtitle: 'Updates for your class'),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.title, required this.subtitle});

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
