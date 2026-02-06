import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService _service = AdminService();

    return FutureBuilder<Map<String, dynamic>>(
      future: _service.getDashboardStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 16, runSpacing: 16,
                children: [
                  _buildStatCard("Total Students", "${data['totalStudents']}", Icons.school, Colors.blue),
                  _buildStatCard("Staff Members", "${data['totalStaff']}", Icons.people, Colors.orange),
                  _buildStatCard("Monthly Collection", "₹ ${data['monthlyCollection']}", Icons.currency_rupee, Colors.green),
                ],
              ),
              
              const SizedBox(height: 20),
              // Gender Split
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildGenderInfo("Boys", "${data['male']}", Colors.blue),
                      Container(width: 1, height: 40, color: Colors.grey),
                      _buildGenderInfo("Girls", "${data['female']}", Colors.pink),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderInfo(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ]),
    );
  }
}