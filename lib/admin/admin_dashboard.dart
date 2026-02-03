import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SummaryCard(
            title: 'Welcome, Principal',
            subtitle: 'Review today’s activity and manage the institution.',
          ),
          _AdminTile(title: 'Dashboard', subtitle: 'Totals and key metrics'),
          _AdminTile(title: 'Academic Year', subtitle: 'Set current year'),
          _AdminTile(title: 'HR Management', subtitle: 'Add staff + passwords'),
          _AdminTile(title: 'Student Management', subtitle: 'Enroll students'),
          _AdminTile(title: 'Fee Structure', subtitle: 'Manage fee plans'),
          _AdminTile(title: 'Public Content', subtitle: 'Update public page'),
          _AdminTile(title: 'Reports', subtitle: 'Income/expense reports'),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.title, required this.subtitle});

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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
