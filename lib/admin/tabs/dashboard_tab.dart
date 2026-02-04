import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Text(
            "Overview (2025-2026)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Stats Grid (Responsive Wrap)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(context, "Total Students", "1,250", Icons.school, Colors.blue),
              _buildStatCard(context, "Total Staff", "85", Icons.people, Colors.orange),
              _buildStatCard(context, "Fee Collected", "₹ 45L", Icons.currency_rupee, Colors.green),
              _buildStatCard(context, "Pending Fee", "₹ 12L", Icons.pending, Colors.red),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity Section
          const Text(
            "Recent Activities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildActivityList(),
        ],
      ),
    );
  }

  // സ്റ്റാറ്റിസ്റ്റിക്സ് കാർഡ് ഡിസൈൻ
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    // സ്ക്രീൻ വലിപ്പം അനുസരിച്ച് കാർഡിന്റെ വീതി ക്രമീകരിക്കുന്നു
    double width = MediaQuery.of(context).size.width > 600 ? 200 : (MediaQuery.of(context).size.width / 2) - 24;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  // റീസെന്റ് ആക്ടിവിറ്റി ലിസ്റ്റ് (Dummy Data)
  Widget _buildActivityList() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true, // സ്ക്രോൾവ്യൂവിനുള്ളിൽ ലിസ്റ്റ് വരുമ്പോൾ ഇത് നിർബന്ധമാണ്
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.notifications_none, size: 20, color: Colors.black54),
            ),
            title: const Text("New Payment received from Class 10 A"),
            subtitle: const Text("2 mins ago • ₹ 5,000"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          );
        },
      ),
    );
  }
}
