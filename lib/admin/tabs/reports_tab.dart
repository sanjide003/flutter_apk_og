import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildReportCard(context, "Daily Collection", Icons.today, Colors.blue),
          _buildReportCard(context, "Monthly Report", Icons.calendar_month, Colors.green),
          _buildReportCard(context, "Pending List", Icons.pending_actions, Colors.red),
          _buildReportCard(context, "Staff Performance", Icons.person_search, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Open Detailed Report View (PDF/Excel Logic)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Generating $title...")));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}